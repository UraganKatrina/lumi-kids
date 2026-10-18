import type { GooglePlayConfig } from '../config';
import { signJwt } from './jwt';
import { type FetchFn, StoreError, storeFetch, type VerifyResult } from './purchase';

export const GOOGLE_TOKEN_URL = 'https://oauth2.googleapis.com/token';
export const GOOGLE_SCOPE = 'https://www.googleapis.com/auth/androidpublisher';
const API = 'https://androidpublisher.googleapis.com/androidpublisher/v3/applications';

interface SubscriptionPurchaseV2 {
  subscriptionState?: string;
  acknowledgementState?: string;
  testPurchase?: unknown;
  lineItems?: { productId?: string; expiryTime?: string }[];
}

const ACTIVE_STATES = new Set(['SUBSCRIPTION_STATE_ACTIVE', 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD']);

/**
 * Проверка подписки Google Play через subscriptionsv2.
 * Покупку сервер не подтверждает (acknowledge): это делает приложение через SDK магазина.
 */
export class GooglePlayVerifier {
  private accessToken: { value: string; expiresAt: number } | null = null;
  private pending: Promise<string> | null = null;

  constructor(
    private readonly config: GooglePlayConfig,
    private readonly fetchFn: FetchFn,
    private readonly now: () => number = Date.now,
  ) {}

  async verify(productId: string, purchaseToken: string): Promise<VerifyResult> {
    const url = `${API}/${encodeURIComponent(this.config.packageName)}/purchases/subscriptionsv2/tokens/${encodeURIComponent(purchaseToken)}`;
    const res = await storeFetch(this.fetchFn, 'google', url, {
      headers: { Authorization: `Bearer ${await this.getAccessToken()}` },
    });
    // 400/404/410 — Google не знает такой токен (подделка, чужое приложение или очень старая покупка).
    if (res.status === 400 || res.status === 404 || res.status === 410) {
      return { active: false, productId, expiresAt: null, platform: 'android', environment: 'production', acknowledged: false };
    }
    if (res.status === 401) this.accessToken = null;
    if (!res.ok) throw new StoreError('google', res.status);

    const body = (await res.json().catch(() => null)) as SubscriptionPurchaseV2 | null;
    if (!body || typeof body !== 'object') throw new StoreError('google', res.status);

    const item = (body.lineItems ?? []).find((li) => li.productId === productId);
    const expiry = item?.expiryTime ? Date.parse(item.expiryTime) : NaN;
    const expiresAt = Number.isFinite(expiry) ? new Date(expiry).toISOString() : null;
    const active = ACTIVE_STATES.has(body.subscriptionState ?? '') && Number.isFinite(expiry) && expiry > this.now();
    return {
      active,
      productId,
      expiresAt,
      platform: 'android',
      // testPurchase есть только у покупок тестировщиков из лицензионного списка.
      environment: body.testPurchase ? 'sandbox' : 'production',
      acknowledged: body.acknowledgementState === 'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED',
    };
  }

  /** OAuth2-токен сервисного аккаунта; хранится в памяти до минуты перед истечением. */
  private async getAccessToken(): Promise<string> {
    if (this.accessToken && this.accessToken.expiresAt > this.now()) return this.accessToken.value;
    // Одновременные запросы ждут один обмен, а не делают свои.
    this.pending ??= this.exchange().finally(() => {
      this.pending = null;
    });
    return this.pending;
  }

  private async exchange(): Promise<string> {
    const iat = Math.floor(this.now() / 1000);
    const header = this.config.privateKeyId ? { kid: this.config.privateKeyId } : {};
    const assertion = signJwt(
      'RS256',
      header,
      { iss: this.config.clientEmail, scope: GOOGLE_SCOPE, aud: GOOGLE_TOKEN_URL, iat, exp: iat + 3600 },
      this.config.privateKey,
    );
    const res = await storeFetch(this.fetchFn, 'google', GOOGLE_TOKEN_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({ grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion }).toString(),
    });
    if (!res.ok) throw new StoreError('google', res.status);
    const body = (await res.json().catch(() => null)) as { access_token?: unknown; expires_in?: unknown } | null;
    if (typeof body?.access_token !== 'string') throw new StoreError('google', res.status);
    const ttlSec = typeof body.expires_in === 'number' ? body.expires_in : 3600;
    this.accessToken = { value: body.access_token, expiresAt: this.now() + Math.max(0, ttlSec - 60) * 1000 };
    return body.access_token;
  }
}
