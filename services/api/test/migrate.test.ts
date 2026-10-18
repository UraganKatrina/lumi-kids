import assert from 'node:assert/strict';
import { test } from 'node:test';

import { migrate } from '../src/db/migrate';
import { freshDatabase } from './helpers';

test('миграции применяются один раз', async () => {
  const db = await freshDatabase();
  try {
    assert.deepEqual(await migrate(db), []);
    const tables = await db.query<{ table_name: string }>(
      `SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY 1`,
    );
    assert.deepEqual(
      tables.map((t) => t.table_name),
      ['audit_log', 'content_packs', 'schema_migrations', 'staff_sessions', 'staff_users', 'task_versions', 'tasks'],
    );
  } finally {
    await db.close();
  }
});
