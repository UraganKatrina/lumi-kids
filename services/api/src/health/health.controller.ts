import { Controller, Get } from '@nestjs/common';

import { Database } from '../db/database';

@Controller('v1/health')
export class HealthController {
  constructor(private readonly db: Database) {}

  @Get()
  async check(): Promise<{ status: 'ok' }> {
    await this.db.query('SELECT 1');
    return { status: 'ok' };
  }
}
