import { Injectable } from '@nestjs/common';

import { Database, type Queryable } from '../db/database';

/** Журнал действий редакции: кто, что и когда изменил. Без данных детей. */
@Injectable()
export class AuditService {
  constructor(private readonly db: Database) {}

  async record(
    actorId: string | null,
    action: string,
    target: string | null,
    details: Record<string, unknown> = {},
    tx: Queryable = this.db.pool,
  ): Promise<void> {
    await tx.query(
      'INSERT INTO audit_log (actor_id, action, target, details) VALUES ($1, $2, $3, $4)',
      [actorId, action, target, JSON.stringify(details)],
    );
  }
}
