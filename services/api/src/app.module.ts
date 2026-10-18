import { type DynamicModule, Module } from '@nestjs/common';

import { AuditService } from './audit/audit.service';
import { APP_CONFIG, type AppConfig } from './config';
import { AdminContentController } from './content/admin-content.controller';
import { PacksService } from './content/packs.service';
import { PublicContentController } from './content/public-content.controller';
import { TaskValidator } from './content/task-validator';
import { TasksService } from './content/tasks.service';
import { Database } from './db/database';
import { HealthController } from './health/health.controller';
import { FETCH, type FetchFn } from './purchases/purchase';
import { PurchasesController } from './purchases/purchases.controller';
import { PurchasesService } from './purchases/purchases.service';
import { RateLimit } from './purchases/rate-limit';
import { AuthController } from './staff/auth.controller';
import { StaffGuard } from './staff/auth.guard';
import { AuthService } from './staff/auth.service';
import { StaffService } from './staff/staff.service';

/** Подмены для тестов: поддельный магазин и своё ограничение частоты. */
export interface AppOverrides {
  fetch?: FetchFn;
  purchaseRateLimit?: RateLimit;
}

/** Модульный монолит: один процесс, модули разделены по папкам. */
@Module({})
export class AppModule {
  static register(config: AppConfig, db: Database, overrides: AppOverrides = {}): DynamicModule {
    return {
      module: AppModule,
      controllers: [
        HealthController,
        AuthController,
        AdminContentController,
        PublicContentController,
        PurchasesController,
      ],
      providers: [
        { provide: APP_CONFIG, useValue: config },
        { provide: Database, useValue: db },
        AuditService,
        AuthService,
        StaffGuard,
        StaffService,
        TaskValidator,
        TasksService,
        PacksService,
        { provide: FETCH, useValue: overrides.fetch ?? globalThis.fetch.bind(globalThis) },
        { provide: RateLimit, useValue: overrides.purchaseRateLimit ?? new RateLimit() },
        PurchasesService,
      ],
    };
  }
}
