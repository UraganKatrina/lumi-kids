import 'reflect-metadata';

import { createApp } from './app';
import { loadConfig } from './config';
import { Database } from './db/database';
import { migrate } from './db/migrate';

async function main(): Promise<void> {
  const config = loadConfig();
  const db = Database.connect(config.databaseUrl);
  if (process.env.MIGRATE_ON_START === '1') await migrate(db);
  const app = await createApp(config, db);
  await app.listen(config.port);
  console.log(`LUMI API слушает порт ${config.port}`);
}

main().catch((error: unknown) => {
  console.error(error);
  process.exitCode = 1;
});
