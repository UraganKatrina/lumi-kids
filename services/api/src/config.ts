import { readFileSync } from 'node:fs';

export interface GooglePlayConfig {
  packageName: string;
  /** Почта и ключ сервисного аккаунта из JSON-файла Google Cloud. */
  clientEmail: string;
  privateKey: string;
  privateKeyId?: string;
}

export interface AppStoreConfig {
  bundleId: string;
  issuerId: string;
  keyId: string;
  /** Содержимое ключа .p8 (PEM). */
  privateKey: string;
  allowSandbox: boolean;
}

export interface PurchasesConfig {
  /** Разрешённые подписки: всё остальное отклоняется сразу. */
  productIds: string[];
  /** Нет — проверка для Android выключена (503). */
  google?: GooglePlayConfig;
  /** Нет — проверка для iOS выключена (503). */
  apple?: AppStoreConfig;
}

export interface AppConfig {
  databaseUrl: string;
  port: number;
  sessionTtlHours: number;
  /** Значение express «trust proxy»: число прокси или их адреса. Нет — сервер смотрит в интернет напрямую. */
  trustProxy?: number | string;
  /** Необязательно: без него проверка покупок просто не настроена. */
  purchases?: PurchasesConfig;
}

export const DEFAULT_PRODUCT_IDS = ['lumi_premium_monthly', 'lumi_premium_yearly'];

/** Настройки только из окружения: в репозитории нет ни паролей, ни ключей. */
export function loadConfig(env: NodeJS.ProcessEnv = process.env): AppConfig {
  const databaseUrl = env.DATABASE_URL;
  if (!databaseUrl) throw new Error('Не задан DATABASE_URL');
  return {
    databaseUrl,
    port: Number(env.PORT ?? 3000),
    sessionTtlHours: Number(env.SESSION_TTL_HOURS ?? 12),
    trustProxy: parseTrustProxy(env.TRUST_PROXY),
    purchases: loadPurchasesConfig(env),
  };
}

function parseTrustProxy(value: string | undefined): number | string | undefined {
  if (!value) return undefined;
  return /^\d+$/.test(value) ? Number(value) : value;
}

export function loadPurchasesConfig(env: NodeJS.ProcessEnv = process.env): PurchasesConfig {
  const productIds = (env.PURCHASE_PRODUCT_IDS ?? DEFAULT_PRODUCT_IDS.join(','))
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  return { productIds, google: loadGoogle(env), apple: loadApple(env) };
}

/** Магазин либо настроен полностью, либо не настроен вовсе: половинчатые настройки — ошибка запуска. */
function requireAllOrNone(env: NodeJS.ProcessEnv, names: string[]): boolean {
  const present = names.filter((n) => env[n]);
  if (present.length === 0) return false;
  if (present.length < names.length) {
    const missing = names.filter((n) => !env[n]);
    throw new Error(`Не заданы ${missing.join(', ')} (заданы ${present.join(', ')})`);
  }
  return true;
}

function loadGoogle(env: NodeJS.ProcessEnv): GooglePlayConfig | undefined {
  if (!requireAllOrNone(env, ['GOOGLE_PLAY_PACKAGE_NAME', 'GOOGLE_SERVICE_ACCOUNT_JSON_FILE'])) return undefined;
  let account: { client_email?: unknown; private_key?: unknown; private_key_id?: unknown };
  try {
    account = JSON.parse(readFileSync(env.GOOGLE_SERVICE_ACCOUNT_JSON_FILE!, 'utf8'));
  } catch {
    // Текст ошибки без содержимого файла: в нём ключ.
    throw new Error('Не удалось прочитать GOOGLE_SERVICE_ACCOUNT_JSON_FILE');
  }
  if (typeof account.client_email !== 'string' || typeof account.private_key !== 'string') {
    throw new Error('В GOOGLE_SERVICE_ACCOUNT_JSON_FILE нет client_email или private_key');
  }
  return {
    packageName: env.GOOGLE_PLAY_PACKAGE_NAME!,
    clientEmail: account.client_email,
    privateKey: account.private_key,
    privateKeyId: typeof account.private_key_id === 'string' ? account.private_key_id : undefined,
  };
}

function loadApple(env: NodeJS.ProcessEnv): AppStoreConfig | undefined {
  const names = ['APPLE_BUNDLE_ID', 'APPLE_ISSUER_ID', 'APPLE_KEY_ID', 'APPLE_PRIVATE_KEY_FILE'];
  if (!requireAllOrNone(env, names)) return undefined;
  let privateKey: string;
  try {
    privateKey = readFileSync(env.APPLE_PRIVATE_KEY_FILE!, 'utf8');
  } catch {
    throw new Error('Не удалось прочитать APPLE_PRIVATE_KEY_FILE');
  }
  return {
    bundleId: env.APPLE_BUNDLE_ID!,
    issuerId: env.APPLE_ISSUER_ID!,
    keyId: env.APPLE_KEY_ID!,
    privateKey,
    allowSandbox: ['1', 'true', 'yes'].includes((env.APPLE_ALLOW_SANDBOX ?? '').toLowerCase()),
  };
}

export const APP_CONFIG = Symbol('APP_CONFIG');
