import { parseArgs } from 'node:util';

import { AuditService } from '../audit/audit.service';
import { loadConfig } from '../config';
import { Database } from '../db/database';
import { isRole } from './staff';
import { StaffService } from './staff.service';

/**
 * Создаёт сотрудника редакции. Пароль берётся из переменной STAFF_PASSWORD,
 * чтобы он не попадал в историю команд.
 *   STAFF_PASSWORD=... npm run create-staff -- --email a@b.c --name Анна --role methodologist
 */
async function main(): Promise<void> {
  const { values } = parseArgs({
    options: { email: { type: 'string' }, name: { type: 'string' }, role: { type: 'string' } },
  });
  const password = process.env.STAFF_PASSWORD;
  if (!values.email || !values.name || !isRole(values.role) || !password) {
    throw new Error('Нужны --email, --name, --role (editor|methodologist|admin) и STAFF_PASSWORD');
  }
  const db = Database.connect(loadConfig().databaseUrl);
  try {
    const staff = await new StaffService(db).create({
      email: values.email,
      name: values.name,
      role: values.role,
      password,
    });
    await new AuditService(db).record(null, 'staff.create', staff.id, { role: staff.role });
    console.log(`Создан сотрудник ${staff.email} (${staff.role})`);
  } finally {
    await db.close();
  }
}

main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
