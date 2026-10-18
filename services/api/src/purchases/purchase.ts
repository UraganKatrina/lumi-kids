export type Platform = 'android' | 'ios';
export type StoreEnvironment = 'production' | 'sandbox';

/** Ответ приложению. Никаких данных о покупателе: только есть ли подписка и до когда. */
export interface VerifyResult {
  active: boolean;
  productId: string;
  expiresAt: string | null;
  platform: Platform;
  environment: StoreEnvironment;
  /** Только Android: подтвердило ли приложение покупку (иначе Google вернёт деньги через 3 дня). */
  acknowledged?: boolean;
}

export type FetchFn = typeof globalThis.fetch;

/** Токен для подмены fetch в тестах. */
export const FETCH = Symbol('FETCH');

/** Время запроса к магазину: дольше ждать нет смысла, приложение повторит. */
export const STORE_TIMEOUT_MS = 10_000;

/**
 * Магазин не ответил или ответил ошибкой. Текст для журнала содержит только
 * код ответа: тело ответа и токены туда не попадают.
 */
export class StoreError extends Error {
  constructor(
    readonly store: 'google' | 'apple',
    readonly status: number | null,
  ) {
    super(`${store}: ${status === null ? 'нет ответа' : `HTTP ${status}`}`);
  }
}

/** Запрос к магазину; сетевая ошибка и таймаут превращаются в StoreError. */
export async function storeFetch(
  fetchFn: FetchFn,
  store: 'google' | 'apple',
  url: string,
  init: RequestInit,
): Promise<Response> {
  try {
    return await fetchFn(url, { ...init, signal: AbortSignal.timeout(STORE_TIMEOUT_MS) });
  } catch {
    throw new StoreError(store, null);
  }
}
