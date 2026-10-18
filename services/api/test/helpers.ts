import 'reflect-metadata';

import type { INestApplication } from '@nestjs/common';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import request from 'supertest';

import { createApp } from '../src/app';
import type { AppConfig } from '../src/config';
import { Database } from '../src/db/database';
import { migrate } from '../src/db/migrate';
import type { Role } from '../src/staff/staff';
import { StaffService } from '../src/staff/staff.service';

export const TEST_DATABASE_URL =
  process.env.TEST_DATABASE_URL ?? 'postgres://postgres@127.0.0.1:5432/lumi_test';

export const PASSWORD = 'correct horse battery';

const EXAMPLES = join(__dirname, '..', '..', '..', '..', 'content', 'examples');

export function example(name: string): Record<string, unknown> {
  return JSON.parse(readFileSync(join(EXAMPLES, `${name}.json`), 'utf8'));
}

/** Пустая база: схема пересоздаётся и мигрирует заново. */
export async function freshDatabase(): Promise<Database> {
  const db = Database.connect(TEST_DATABASE_URL);
  await db.query('DROP SCHEMA public CASCADE');
  await db.query('CREATE SCHEMA public');
  await migrate(db);
  return db;
}

export interface TestContext {
  app: INestApplication;
  db: Database;
  http: () => ReturnType<typeof request>;
  tokens: Record<'editor' | 'editor2' | 'methodologist' | 'admin', string>;
  close: () => Promise<void>;
}

export async function startApp(): Promise<TestContext> {
  const db = await freshDatabase();
  const config: AppConfig = { databaseUrl: TEST_DATABASE_URL, port: 0, sessionTtlHours: 1 };
  const app = await createApp(config, db);
  await app.init();
  const http = () => request(app.getHttpServer());

  const staff = new StaffService(db);
  const people: [keyof TestContext['tokens'], Role][] = [
    ['editor', 'editor'],
    ['editor2', 'editor'],
    ['methodologist', 'methodologist'],
    ['admin', 'admin'],
  ];
  const tokens = {} as TestContext['tokens'];
  for (const [name, role] of people) {
    const email = `${name}@lumi.test`;
    await staff.create({ email, name, role, password: PASSWORD });
    const res = await http().post('/v1/admin/login').send({ email, password: PASSWORD }).expect(200);
    tokens[name] = res.body.token;
  }
  return {
    app,
    db,
    http,
    tokens,
    close: async () => {
      await app.close();
      await db.close();
    },
  };
}

export const bearer = (token: string) => ({ Authorization: `Bearer ${token}` });
