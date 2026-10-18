import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

import type { Database } from './database';

export const MIGRATIONS_DIR = join(__dirname, '..', '..', '..', 'migrations');

/**
 * Применяет новые SQL-миграции по порядку имён, каждую в своей транзакции.
 * Уже применённые пропускаются. Возвращает имена применённых сейчас.
 */
export async function migrate(db: Database, dir = MIGRATIONS_DIR): Promise<string[]> {
  await db.query(`CREATE TABLE IF NOT EXISTS schema_migrations (
    name text PRIMARY KEY,
    applied_at timestamptz NOT NULL DEFAULT now()
  )`);
  const done = new Set(
    (await db.query<{ name: string }>('SELECT name FROM schema_migrations')).map((r) => r.name),
  );
  const applied: string[] = [];
  for (const name of readdirSync(dir).filter((f) => f.endsWith('.sql')).sort()) {
    if (done.has(name)) continue;
    const sql = readFileSync(join(dir, name), 'utf8');
    await db.transaction(async (tx) => {
      await tx.query(sql);
      await tx.query('INSERT INTO schema_migrations (name) VALUES ($1)', [name]);
    });
    applied.push(name);
  }
  return applied;
}
