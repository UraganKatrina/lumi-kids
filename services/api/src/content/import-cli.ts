import { readFileSync } from 'node:fs';
import { parseArgs } from 'node:util';

import { AuditService } from '../audit/audit.service';
import { loadConfig } from '../config';
import { Database } from '../db/database';
import type { StaffUser } from '../staff/staff';
import { importTasks } from './import-tasks';
import { TaskValidator } from './task-validator';
import { TasksService } from './tasks.service';

/**
 * Импорт заданий из файла пакета в черновики.
 *   npm run import-tasks -- --file ../../apps/mobile/assets/content/starter_pack.json --as editor@example.com
 */
async function main(): Promise<void> {
  const { values } = parseArgs({ options: { file: { type: 'string' }, as: { type: 'string' } } });
  if (!values.file || !values.as) throw new Error('Нужны --file и --as (почта сотрудника)');
  const pack = JSON.parse(readFileSync(values.file, 'utf8')) as { tasks?: unknown };
  if (!Array.isArray(pack.tasks)) throw new Error('В файле нет списка tasks');

  const db = Database.connect(loadConfig().databaseUrl);
  try {
    const [staff] = await db.query<StaffUser>(
      'SELECT id, email, name, role FROM staff_users WHERE email = lower($1) AND disabled_at IS NULL',
      [values.as],
    );
    if (!staff) throw new Error(`Нет сотрудника ${values.as}`);
    const validator = new TaskValidator();
    await validator.onModuleInit();
    const report = await importTasks(new TasksService(db, validator, new AuditService(db)), staff, pack.tasks);
    console.log(`Создано черновиков: ${report.created.length}, уже были: ${report.skipped.length}`);
    for (const f of report.failed) console.log(`Ошибка в ${f.id}: ${f.errors.join('; ')}`);
    if (report.failed.length) process.exitCode = 1;
  } finally {
    await db.close();
  }
}

main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
