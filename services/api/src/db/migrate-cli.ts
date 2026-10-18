import { loadConfig } from '../config';
import { Database } from './database';
import { migrate } from './migrate';

async function main(): Promise<void> {
  const db = Database.connect(loadConfig().databaseUrl);
  try {
    const applied = await migrate(db);
    console.log(applied.length ? `Применены: ${applied.join(', ')}` : 'Новых миграций нет');
  } finally {
    await db.close();
  }
}

main().catch((error: unknown) => {
  console.error(error);
  process.exitCode = 1;
});
