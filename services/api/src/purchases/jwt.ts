import { createPrivateKey, sign, type KeyObject } from 'node:crypto';

/** base64url без выравнивания, как требует JWT. */
export function base64url(data: Buffer | string): string {
  return Buffer.from(data).toString('base64url');
}

/**
 * Подписывает JWT ключом [privateKey] (PEM).
 * RS256 — для сервисного аккаунта Google, ES256 — для ключа App Store (.p8).
 * Для ES256 подпись нужна в виде r||s (ieee-p1363), а не DER, иначе Apple её не примет.
 */
export function signJwt(
  alg: 'RS256' | 'ES256',
  header: Record<string, unknown>,
  payload: Record<string, unknown>,
  privateKey: string | KeyObject,
): string {
  const key = typeof privateKey === 'string' ? createPrivateKey(privateKey) : privateKey;
  const input = `${base64url(JSON.stringify({ ...header, alg, typ: 'JWT' }))}.${base64url(JSON.stringify(payload))}`;
  const signature =
    alg === 'ES256'
      ? sign('sha256', Buffer.from(input), { key, dsaEncoding: 'ieee-p1363' })
      : sign('sha256', Buffer.from(input), key);
  return `${input}.${base64url(signature)}`;
}

/**
 * Читает полезную нагрузку JWS без проверки подписи.
 * Годится только для данных, полученных напрямую от магазина по TLS
 * нашим же запросом с нашими ключами (см. app-store.verifier.ts).
 */
export function decodeJwsPayload<T>(jws: string): T {
  const parts = jws.split('.');
  if (parts.length !== 3 || !parts[1]) throw new Error('Неверный формат JWS');
  return JSON.parse(Buffer.from(parts[1], 'base64url').toString('utf8')) as T;
}
