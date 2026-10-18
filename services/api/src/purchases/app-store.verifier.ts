import type { AppStoreConfig } from '../config';
import { decodeJwsPayload, signJwt } from './jwt';
import { type FetchFn, StoreError, storeFetch, type StoreEnvironment, type VerifyResult } from './purchase';

export const APPLE_HOSTS: Record<StoreEnvironment, string> = {
  production: 'https://api.storekit.itunes.apple.com',
  sandbox: 'https://api.storekit-sandbox.itunes.apple.com',
};

interface SubscriptionStatusResponse {
  bundleId?: string;
  data?: { lastTransactions?: { status?: number; signedTransactionInfo?: string }[] }[];
}

interface TransactionPayload {
  bundleId?: string;
  productId?: string;
  expiresDate?: number;
}

/** 1 — активна, 4 — льготный период после неудачного списания. */
const ACTIVE_STATUSES = new Set([1, 4]);

/** Проверка подписки через App Store Server API (Get All Subscription Statuses). */
export class AppStoreVerifier {
  constructor(
    private readonly config: AppStoreConfig,
    private readonly fetchFn: FetchFn,
    private readonly now: () => number = Date.now,
  ) {}

  async verify(productId: string, transactionId: string): Promise<VerifyResult> {
    let environment: StoreEnvironment = 'production';
    let res = await this.request(environment, transactionId);
    // Покупки из TestFlight и Xcode живут только в песочнице.
    if (res.status === 404 && this.config.allowSandbox) {
      environment = 'sandbox';
      res = await this.request(environment, transactionId);
    }
    const inactive: VerifyResult = { active: false, productId, expiresAt: null, platform: 'ios', environment };
    // 400 — неверный номер транзакции, 404 — такой транзакции у нашего приложения нет.
    if (res.status === 400 || res.status === 404) return inactive;
    if (!res.ok) throw new StoreError('apple', res.status);

    const body = (await res.json().catch(() => null)) as SubscriptionStatusResponse | null;
    if (!body || typeof body !== 'object') throw new StoreError('apple', res.status);
    if (body.bundleId !== undefined && body.bundleId !== this.config.bundleId) return inactive;

    let best: { active: boolean; expires: number } | null = null;
    for (const group of body.data ?? []) {
      for (const last of group.lastTransactions ?? []) {
        if (typeof last.signedTransactionInfo !== 'string') continue;
        // Подпись JWS (цепочку x5c) не проверяем: ответ пришёл напрямую от Apple
        // по TLS на наш запрос, подписанный нашим ключом, — подделать его по пути нельзя.
        // Если когда-нибудь начнём принимать JWS от приложения, проверка цепочки обязательна.
        let tx: TransactionPayload;
        try {
          tx = decodeJwsPayload<TransactionPayload>(last.signedTransactionInfo);
        } catch {
          throw new StoreError('apple', res.status);
        }
        if (tx.productId !== productId || tx.bundleId !== this.config.bundleId) continue;
        const expires = typeof tx.expiresDate === 'number' ? tx.expiresDate : NaN;
        const active = ACTIVE_STATUSES.has(last.status ?? 0) && Number.isFinite(expires) && expires > this.now();
        if (!best || (active && !best.active) || (active === best.active && expires > best.expires)) {
          best = { active, expires };
        }
      }
    }
    if (!best) return inactive;
    return {
      ...inactive,
      active: best.active,
      expiresAt: Number.isFinite(best.expires) ? new Date(best.expires).toISOString() : null,
    };
  }

  private request(environment: StoreEnvironment, transactionId: string): Promise<Response> {
    const url = `${APPLE_HOSTS[environment]}/inApps/v1/subscriptions/${encodeURIComponent(transactionId)}`;
    return storeFetch(this.fetchFn, 'apple', url, { headers: { Authorization: `Bearer ${this.token()}` } });
  }

  /** Токен App Store Connect API: живёт 20 минут (Apple разрешает не больше 60). */
  private token(): string {
    const iat = Math.floor(this.now() / 1000);
    return signJwt(
      'ES256',
      { kid: this.config.keyId },
      { iss: this.config.issuerId, iat, exp: iat + 20 * 60, aud: 'appstoreconnect-v1', bid: this.config.bundleId },
      this.config.privateKey,
    );
  }
}
