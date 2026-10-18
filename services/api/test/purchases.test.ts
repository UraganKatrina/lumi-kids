import 'reflect-metadata';

import assert from 'node:assert/strict';
import { generateKeyPairSync, verify, type KeyObject } from 'node:crypto';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { after, before, describe, test } from 'node:test';

import type { INestApplication } from '@nestjs/common';
import request from 'supertest';

import { createApp } from '../src/app';
import { DEFAULT_PRODUCT_IDS, loadConfig, type PurchasesConfig } from '../src/config';
import { Database } from '../src/db/database';
import { GOOGLE_SCOPE, GOOGLE_TOKEN_URL } from '../src/purchases/google-play.verifier';
import { base64url, decodeJwsPayload, signJwt } from '../src/purchases/jwt';
import type { FetchFn } from '../src/purchases/purchase';
import { RateLimit } from '../src/purchases/rate-limit';
import { TEST_DATABASE_URL } from './helpers';

// Одноразовые ключи: настоящих ключей Google и Apple в тестах нет.
const rsa = generateKeyPairSync('rsa', { modulusLength: 2048 });
const ec = generateKeyPairSync('ec', { namedCurve: 'P-256' });
const pem = (key: KeyObject) => key.export({ type: 'pkcs8', format: 'pem' }).toString();

const PACKAGE = 'kids.lumi.app';
const BUNDLE = 'kids.lumi.app';
const MONTHLY = 'lumi_premium_monthly';
const ANDROID_TOKEN = 'secret-purchase-token.AO-J1Oz_test';
const HOUR = 3600_000;

const purchasesConfig = (overrides: Partial<PurchasesConfig> = {}, allowSandbox = false): PurchasesConfig => ({
  productIds: DEFAULT_PRODUCT_IDS,
  google: { packageName: PACKAGE, clientEmail: 'verifier@lumi.iam.gserviceaccount.com', privateKey: pem(rsa.privateKey), privateKeyId: 'rsa-kid' },
  apple: { bundleId: BUNDLE, issuerId: 'issuer-uuid', keyId: 'APPLEKEY1', privateKey: pem(ec.privateKey), allowSandbox },
  ...overrides,
});

function parseJwt(jwt: string) {
  const [h, p, s] = jwt.split('.');
  return {
    header: JSON.parse(Buffer.from(h!, 'base64url').toString()),
    payload: JSON.parse(Buffer.from(p!, 'base64url').toString()),
    input: Buffer.from(`${h}.${p}`),
    signature: Buffer.from(s!, 'base64url'),
  };
}

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });

interface Call {
  url: string;
  init: RequestInit;
}

/** Поддельный магазин: [route] решает, что ответить на каждый запрос. */
function fakeStore(route: (url: string, init: RequestInit) => Response | Promise<Response>) {
  const calls: Call[] = [];
  const fetchFn = (async (input: string | URL | Request, init: RequestInit = {}) => {
    const url = String(input);
    calls.push({ url, init });
    return route(url, init);
  }) as FetchFn;
  return { calls, fetchFn };
}

const auth = (call: Call) => (call.init.headers as Record<string, string>).Authorization!;

function googleRoute(subscription: (token: string) => Response) {
  return (url: string) => {
    if (url === GOOGLE_TOKEN_URL) return json(200, { access_token: 'ya29.fake', expires_in: 3599, token_type: 'Bearer' });
    const prefix = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${PACKAGE}/purchases/subscriptionsv2/tokens/`;
    if (url.startsWith(prefix)) return subscription(decodeURIComponent(url.slice(prefix.length)));
    return json(404, {});
  };
}

const googleSubscription = (state: string, productId: string, expiry: number, extra: Record<string, unknown> = {}) =>
  json(200, {
    kind: 'androidpublisher#subscriptionPurchaseV2',
    subscriptionState: state,
    acknowledgementState: 'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED',
    lineItems: [{ productId, expiryTime: new Date(expiry).toISOString() }],
    ...extra,
  });

/** Ответ Get All Subscription Statuses с одной транзакцией. */
function appleStatus(status: number, tx: { productId?: string; bundleId?: string; expiresDate?: number }, environment = 'Production') {
  const signedTransactionInfo = `${base64url('{"alg":"ES256","x5c":[]}')}.${base64url(
    JSON.stringify({ transactionId: '2000000123', originalTransactionId: '2000000100', bundleId: BUNDLE, productId: MONTHLY, environment, ...tx }),
  )}.c2lnbmF0dXJl`;
  return json(200, {
    environment,
    bundleId: BUNDLE,
    appAppleId: 123,
    data: [{ subscriptionGroupIdentifier: '1', lastTransactions: [{ originalTransactionId: '2000000100', status, signedTransactionInfo }] }],
  });
}

async function startPurchasesApp(purchases: PurchasesConfig | undefined, fetchFn: FetchFn, rateLimit?: RateLimit) {
  // Проверка покупок базу не трогает; соединение нужно только конструктору приложения.
  const db = Database.connect(TEST_DATABASE_URL);
  const app: INestApplication = await createApp(
    { databaseUrl: TEST_DATABASE_URL, port: 0, sessionTtlHours: 1, purchases },
    db,
    { fetch: fetchFn, purchaseRateLimit: rateLimit ?? new RateLimit(1000) },
  );
  await app.init();
  return {
    post: (body: unknown) => request(app.getHttpServer()).post('/v1/purchases/verify').send(body as object),
    close: async () => {
      await app.close();
      await db.close();
    },
  };
}

describe('подпись JWT', () => {
  test('ES256 подписывается в формате ieee-p1363 и проверяется открытым ключом', () => {
    const jwt = signJwt('ES256', { kid: 'K1' }, { iss: 'i', n: 1 }, pem(ec.privateKey));
    const { header, payload, input, signature } = parseJwt(jwt);
    assert.deepEqual(header, { kid: 'K1', alg: 'ES256', typ: 'JWT' });
    assert.deepEqual(payload, { iss: 'i', n: 1 });
    // r||s для P-256 — ровно 64 байта, DER был бы длиннее и переменной длины.
    assert.equal(signature.length, 64);
    assert.equal(verify('sha256', input, { key: ec.publicKey, dsaEncoding: 'ieee-p1363' }, signature), true);
    assert.equal(verify('sha256', Buffer.from('другое'), { key: ec.publicKey, dsaEncoding: 'ieee-p1363' }, signature), false);
  });

  test('RS256 проверяется открытым ключом', () => {
    const { input, signature, header } = parseJwt(signJwt('RS256', {}, { a: 'б' }, pem(rsa.privateKey)));
    assert.equal(header.alg, 'RS256');
    assert.equal(verify('sha256', input, rsa.publicKey, signature), true);
  });

  test('полезная нагрузка JWS читается, мусор — ошибка', () => {
    assert.deepEqual(decodeJwsPayload(`x.${base64url('{"a":1}')}.y`), { a: 1 });
    assert.throws(() => decodeJwsPayload('не-jws'));
  });
});

describe('настройки покупок', () => {
  let dir: string;
  before(() => {
    dir = mkdtempSync(join(tmpdir(), 'lumi-purchases-'));
  });
  after(() => rmSync(dir, { recursive: true, force: true }));

  test('без переменных магазины не настроены, продукты по умолчанию', () => {
    const config = loadConfig({ DATABASE_URL: 'postgres://x' });
    assert.deepEqual(config.purchases, { productIds: DEFAULT_PRODUCT_IDS, google: undefined, apple: undefined });
    assert.equal(config.trustProxy, undefined);
  });

  test('ключи читаются из файлов при запуске', () => {
    const account = join(dir, 'sa.json');
    const p8 = join(dir, 'key.p8');
    writeFileSync(account, JSON.stringify({ client_email: 'a@b', private_key: 'PEM', private_key_id: 'k' }));
    writeFileSync(p8, 'P8');
    const { purchases } = loadConfig({
      DATABASE_URL: 'postgres://x',
      PURCHASE_PRODUCT_IDS: ' a , b ,',
      GOOGLE_PLAY_PACKAGE_NAME: 'pkg',
      GOOGLE_SERVICE_ACCOUNT_JSON_FILE: account,
      APPLE_BUNDLE_ID: 'bid',
      APPLE_ISSUER_ID: 'iss',
      APPLE_KEY_ID: 'kid',
      APPLE_PRIVATE_KEY_FILE: p8,
      APPLE_ALLOW_SANDBOX: 'true',
    });
    assert.deepEqual(purchases?.productIds, ['a', 'b']);
    assert.deepEqual(purchases?.google, { packageName: 'pkg', clientEmail: 'a@b', privateKey: 'PEM', privateKeyId: 'k' });
    assert.deepEqual(purchases?.apple, { bundleId: 'bid', issuerId: 'iss', keyId: 'kid', privateKey: 'P8', allowSandbox: true });
  });

  test('половинчатые настройки магазина не дают запуститься', () => {
    assert.throws(() => loadConfig({ DATABASE_URL: 'x', APPLE_BUNDLE_ID: 'bid' }), /APPLE_ISSUER_ID/);
    assert.throws(
      () => loadConfig({ DATABASE_URL: 'x', GOOGLE_PLAY_PACKAGE_NAME: 'p', GOOGLE_SERVICE_ACCOUNT_JSON_FILE: join(dir, 'нет.json') }),
      /GOOGLE_SERVICE_ACCOUNT_JSON_FILE/,
    );
  });
});

test('ограничение частоты по адресу', () => {
  let now = 0;
  const limit = new RateLimit(2, 1000, () => now);
  assert.equal(limit.take('a'), true);
  assert.equal(limit.take('a'), true);
  assert.equal(limit.take('a'), false);
  assert.equal(limit.take('b'), true);
  now = 1000;
  assert.equal(limit.take('a'), true);
});

describe('POST /v1/purchases/verify — Android', () => {
  let subscription: (token: string) => Response;
  const store = fakeStore(googleRoute((token) => subscription(token)));
  let app: Awaited<ReturnType<typeof startPurchasesApp>>;
  before(async () => {
    app = await startPurchasesApp(purchasesConfig(), store.fetchFn);
  });
  after(() => app.close());

  test('активная подписка; токен Google получен по JWT сервисного аккаунта', async () => {
    const expiry = Date.now() + 24 * HOUR;
    subscription = (token) =>
      token === ANDROID_TOKEN ? googleSubscription('SUBSCRIPTION_STATE_ACTIVE', MONTHLY, expiry) : json(404, {});
    const res = await app.post({ platform: 'android', productId: MONTHLY, token: ANDROID_TOKEN }).expect(200);
    assert.deepEqual(res.body, {
      active: true,
      productId: MONTHLY,
      expiresAt: new Date(expiry).toISOString(),
      platform: 'android',
      environment: 'production',
      acknowledged: true,
    });

    const [exchange, get] = store.calls;
    assert.equal(exchange!.url, GOOGLE_TOKEN_URL);
    assert.equal(exchange!.init.method, 'POST');
    const form = new URLSearchParams(String(exchange!.init.body));
    assert.equal(form.get('grant_type'), 'urn:ietf:params:oauth:grant-type:jwt-bearer');
    const jwt = parseJwt(form.get('assertion')!);
    assert.equal(verify('sha256', jwt.input, rsa.publicKey, jwt.signature), true);
    assert.deepEqual(jwt.header, { kid: 'rsa-kid', alg: 'RS256', typ: 'JWT' });
    assert.equal(jwt.payload.iss, 'verifier@lumi.iam.gserviceaccount.com');
    assert.equal(jwt.payload.scope, GOOGLE_SCOPE);
    assert.equal(jwt.payload.aud, GOOGLE_TOKEN_URL);
    assert.equal(jwt.payload.exp - jwt.payload.iat, 3600);
    assert.ok(Math.abs(jwt.payload.iat - Date.now() / 1000) < 60);

    assert.match(get!.url, new RegExp(`/applications/${PACKAGE}/purchases/subscriptionsv2/tokens/`));
    assert.equal(auth(get!), 'Bearer ya29.fake');
    // Сервер покупку не подтверждает: только чтение.
    assert.ok(store.calls.every((c) => !c.url.includes(':acknowledge')));
  });

  test('токен Google кэшируется; льготный период — тоже активна; неподтверждённая покупка видна', async () => {
    const before = store.calls.length;
    subscription = () =>
      googleSubscription('SUBSCRIPTION_STATE_IN_GRACE_PERIOD', MONTHLY, Date.now() + HOUR, {
        acknowledgementState: 'ACKNOWLEDGEMENT_STATE_PENDING',
        testPurchase: {},
      });
    const res = await app.post({ platform: 'android', productId: MONTHLY, token: ANDROID_TOKEN }).expect(200);
    assert.equal(res.body.active, true);
    assert.equal(res.body.acknowledged, false);
    assert.equal(res.body.environment, 'sandbox');
    assert.deepEqual(
      store.calls.slice(before).map((c) => c.url === GOOGLE_TOKEN_URL),
      [false],
    );
  });

  test('истёкшая подписка не активна', async () => {
    const expiry = Date.now() - HOUR;
    subscription = () => googleSubscription('SUBSCRIPTION_STATE_EXPIRED', MONTHLY, expiry);
    const res = await app.post({ platform: 'android', productId: MONTHLY, token: ANDROID_TOKEN }).expect(200);
    assert.equal(res.body.active, false);
    assert.equal(res.body.expiresAt, new Date(expiry).toISOString());

    // Состояние «активна», но срок уже прошёл, — тоже не активна.
    subscription = () => googleSubscription('SUBSCRIPTION_STATE_ACTIVE', MONTHLY, expiry);
    assert.equal((await app.post({ platform: 'android', productId: MONTHLY, token: ANDROID_TOKEN })).body.active, false);
  });

  test('покупка другого продукта не засчитывается; чужой продукт отклоняется сразу', async () => {
    subscription = () => googleSubscription('SUBSCRIPTION_STATE_ACTIVE', 'lumi_premium_yearly', Date.now() + HOUR);
    const res = await app.post({ platform: 'android', productId: MONTHLY, token: ANDROID_TOKEN }).expect(200);
    assert.equal(res.body.active, false);
    assert.equal(res.body.expiresAt, null);

    const before = store.calls.length;
    const bad = await app.post({ platform: 'android', productId: 'coins_9999', token: ANDROID_TOKEN }).expect(400);
    assert.equal(bad.body.message, 'Неизвестный продукт');
    assert.equal(store.calls.length, before);
  });

  test('неизвестный Google токен — не активна', async () => {
    subscription = () => json(410, { error: { message: 'gone' } });
    const res = await app.post({ platform: 'android', productId: MONTHLY, token: 'unknown' }).expect(200);
    assert.equal(res.body.active, false);
  });

  test('ошибка Google — 502 без тела ответа и без токена в журнале', async () => {
    subscription = () => json(500, { error: { message: 'internal upstream detail ya29.fake' } });
    const written: string[] = [];
    const original = { out: process.stdout.write, err: process.stderr.write };
    const capture = (chunk: unknown) => {
      written.push(String(chunk));
      return true;
    };
    process.stdout.write = capture as typeof process.stdout.write;
    process.stderr.write = capture as typeof process.stderr.write;
    let res;
    try {
      res = await app.post({ platform: 'android', productId: MONTHLY, token: ANDROID_TOKEN });
    } finally {
      process.stdout.write = original.out;
      process.stderr.write = original.err;
    }
    assert.equal(res.status, 502);
    assert.ok(!res.text.includes('upstream'));
    assert.ok(!res.text.includes('ya29'));
    const log = written.join('');
    assert.ok(log.includes('HTTP 500'), log);
    assert.ok(!log.includes(ANDROID_TOKEN));
    assert.ok(!log.includes('ya29'));
  });

  test('неверный запрос — 400', async () => {
    const cases: unknown[] = [
      {},
      { platform: 'web', productId: MONTHLY, token: 'x' },
      { platform: 'android', productId: MONTHLY },
      { platform: 'android', productId: MONTHLY, token: '' },
      { platform: 'android', productId: MONTHLY, token: 'x'.repeat(4097) },
      { platform: 'android', productId: MONTHLY, token: 'с пробелом' },
      { platform: 'ios', productId: MONTHLY, token: '../../v1/apps' },
      { platform: 'android', productId: 42, token: 'x' },
    ];
    for (const body of cases) {
      const res = await app.post(body);
      assert.equal(res.status, 400, JSON.stringify(body).slice(0, 80));
      assert.match(res.body.message, /[а-яА-Я]/);
    }
  });
});

describe('POST /v1/purchases/verify — iOS', () => {
  let production: (id: string) => Response;
  let sandbox: (id: string) => Response;
  const route = (url: string) => {
    for (const [host, handler] of [
      ['https://api.storekit.itunes.apple.com/inApps/v1/subscriptions/', () => production],
      ['https://api.storekit-sandbox.itunes.apple.com/inApps/v1/subscriptions/', () => sandbox],
    ] as const) {
      if (url.startsWith(host)) return handler()(url.slice(host.length));
    }
    return json(404, {});
  };
  const strict = fakeStore(route);
  const lenient = fakeStore(route);
  let app: Awaited<ReturnType<typeof startPurchasesApp>>;
  let sandboxApp: Awaited<ReturnType<typeof startPurchasesApp>>;
  before(async () => {
    app = await startPurchasesApp(purchasesConfig(), strict.fetchFn);
    sandboxApp = await startPurchasesApp(purchasesConfig({}, true), lenient.fetchFn);
  });
  after(async () => {
    await app.close();
    await sandboxApp.close();
  });

  const notFound = () => json(404, { errorCode: 4040010, errorMessage: 'Transaction id not found.' });

  test('активная подписка; токен App Store подписан ES256 с нужными полями', async () => {
    const expiry = Date.now() + 24 * HOUR;
    production = (id) => (id === '2000000123' ? appleStatus(1, { expiresDate: expiry }) : notFound());
    const res = await app.post({ platform: 'ios', productId: MONTHLY, token: '2000000123' }).expect(200);
    assert.deepEqual(res.body, {
      active: true,
      productId: MONTHLY,
      expiresAt: new Date(expiry).toISOString(),
      platform: 'ios',
      environment: 'production',
    });

    const jwt = parseJwt(auth(strict.calls[0]!).replace(/^Bearer /, ''));
    assert.deepEqual(jwt.header, { kid: 'APPLEKEY1', alg: 'ES256', typ: 'JWT' });
    assert.equal(jwt.payload.iss, 'issuer-uuid');
    assert.equal(jwt.payload.aud, 'appstoreconnect-v1');
    assert.equal(jwt.payload.bid, BUNDLE);
    assert.ok(jwt.payload.exp - jwt.payload.iat <= 3600);
    assert.equal(verify('sha256', jwt.input, { key: ec.publicKey, dsaEncoding: 'ieee-p1363' }, jwt.signature), true);
  });

  test('льготный период — активна; истёкшая и отозванная — нет', async () => {
    production = () => appleStatus(4, { expiresDate: Date.now() + HOUR });
    assert.equal((await app.post({ platform: 'ios', productId: MONTHLY, token: '1' })).body.active, true);
    production = () => appleStatus(2, { expiresDate: Date.now() - HOUR });
    assert.equal((await app.post({ platform: 'ios', productId: MONTHLY, token: '1' })).body.active, false);
    production = () => appleStatus(1, { expiresDate: Date.now() - HOUR });
    assert.equal((await app.post({ platform: 'ios', productId: MONTHLY, token: '1' })).body.active, false);
    production = () => appleStatus(5, { expiresDate: Date.now() + HOUR });
    assert.equal((await app.post({ platform: 'ios', productId: MONTHLY, token: '1' })).body.active, false);
  });

  test('чужой bundleId или другой продукт — не активна', async () => {
    production = () => appleStatus(1, { bundleId: 'com.other.app', expiresDate: Date.now() + HOUR });
    const res = await app.post({ platform: 'ios', productId: MONTHLY, token: '1' }).expect(200);
    assert.equal(res.body.active, false);
    assert.equal(res.body.expiresAt, null);

    production = () => appleStatus(1, { productId: 'lumi_premium_yearly', expiresDate: Date.now() + HOUR });
    assert.equal((await app.post({ platform: 'ios', productId: MONTHLY, token: '1' })).body.active, false);
  });

  test('песочница проверяется только если разрешена', async () => {
    production = notFound;
    sandbox = () => appleStatus(1, { expiresDate: Date.now() + HOUR }, 'Sandbox');

    const before = strict.calls.length;
    const denied = await app.post({ platform: 'ios', productId: MONTHLY, token: '777' }).expect(200);
    assert.equal(denied.body.active, false);
    assert.equal(denied.body.environment, 'production');
    assert.deepEqual(
      strict.calls.slice(before).map((c) => new URL(c.url).host),
      ['api.storekit.itunes.apple.com'],
    );

    const allowed = await sandboxApp.post({ platform: 'ios', productId: MONTHLY, token: '777' }).expect(200);
    assert.equal(allowed.body.active, true);
    assert.equal(allowed.body.environment, 'sandbox');
    assert.deepEqual(
      lenient.calls.map((c) => new URL(c.url).host),
      ['api.storekit.itunes.apple.com', 'api.storekit-sandbox.itunes.apple.com'],
    );
  });

  test('ошибка Apple — 502', async () => {
    production = () => json(500, { errorCode: 5000000, errorMessage: 'upstream secret detail' });
    const res = await app.post({ platform: 'ios', productId: MONTHLY, token: '1' }).expect(502);
    assert.ok(!res.text.includes('secret'));
    production = () => json(401, {});
    await app.post({ platform: 'ios', productId: MONTHLY, token: '1' }).expect(502);
  });
});

describe('POST /v1/purchases/verify — настройки и защита', () => {
  test('ненастроенный магазин — 503', async () => {
    const store = fakeStore(() => json(500, {}));
    const app = await startPurchasesApp(purchasesConfig({ google: undefined }), store.fetchFn);
    try {
      const res = await app.post({ platform: 'android', productId: MONTHLY, token: 'x' }).expect(503);
      assert.equal(res.body.message, 'Проверка покупок для Android не настроена');
      assert.equal(store.calls.length, 0);
    } finally {
      await app.close();
    }

    const bare = await startPurchasesApp(undefined, store.fetchFn);
    try {
      const res = await bare.post({ platform: 'ios', productId: MONTHLY, token: '1' }).expect(400);
      assert.equal(res.body.message, 'Неизвестный продукт');
      const configured = await startPurchasesApp({ productIds: [MONTHLY] }, store.fetchFn);
      try {
        const ios = await configured.post({ platform: 'ios', productId: MONTHLY, token: '1' }).expect(503);
        assert.equal(ios.body.message, 'Проверка покупок для iOS не настроена');
      } finally {
        await configured.close();
      }
    } finally {
      await bare.close();
    }
  });

  test('слишком частые запросы с одного адреса — 429', async () => {
    const store = fakeStore(() => json(500, {}));
    const app = await startPurchasesApp(purchasesConfig({ google: undefined }), store.fetchFn, new RateLimit(2));
    try {
      await app.post({ platform: 'android', productId: MONTHLY, token: 'x' }).expect(503);
      await app.post({ platform: 'android', productId: MONTHLY, token: 'x' }).expect(503);
      const res = await app.post({ platform: 'android', productId: MONTHLY, token: 'x' }).expect(429);
      assert.match(res.body.message, /Слишком много/);
    } finally {
      await app.close();
    }
  });
});
