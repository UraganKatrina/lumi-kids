import { type INestApplication } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import type { NestExpressApplication } from '@nestjs/platform-express';

import { AppModule } from './app.module';
import type { AppConfig } from './config';
import type { Database } from './db/database';

export async function createApp(config: AppConfig, db: Database): Promise<INestApplication> {
  const app = await NestFactory.create<NestExpressApplication>(AppModule.register(config, db), {
    logger: ['error', 'warn'],
  });
  // Админка ходит на сервер со своего сервера, поэтому CORS не включаем.
  // Размер тела запроса ограничен стандартными 100 КБ: задание намного меньше.
  app.disable('x-powered-by');
  app.enableShutdownHooks();
  return app;
}
