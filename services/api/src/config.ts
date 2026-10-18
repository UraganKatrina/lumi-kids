export interface AppConfig {
  databaseUrl: string;
  port: number;
  sessionTtlHours: number;
}

/** Настройки только из окружения: в репозитории нет ни паролей, ни ключей. */
export function loadConfig(env: NodeJS.ProcessEnv = process.env): AppConfig {
  const databaseUrl = env.DATABASE_URL;
  if (!databaseUrl) throw new Error('Не задан DATABASE_URL');
  return {
    databaseUrl,
    port: Number(env.PORT ?? 3000),
    sessionTtlHours: Number(env.SESSION_TTL_HOURS ?? 12),
  };
}

export const APP_CONFIG = Symbol('APP_CONFIG');
