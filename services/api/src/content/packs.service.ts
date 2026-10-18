import { ConflictException, Injectable, NotFoundException, UnprocessableEntityException } from '@nestjs/common';
import { createHash } from 'node:crypto';

import { AuditService } from '../audit/audit.service';
import { Database } from '../db/database';
import type { StaffUser } from '../staff/staff';
import type { TaskBody } from './tasks.service';
import { TaskValidator } from './task-validator';

export const PACK_ID = 'main';
const LANGUAGES = ['ru', 'uz', 'en'] as const;

export interface PackSummary {
  version: number;
  sha256: string;
  taskCount: number;
  publishedAt: string;
  publishedBy: string;
}

export interface PublishedPack {
  version: number;
  sha256: string;
  /** JSON пакета ровно в том виде, по которому посчитан sha256. */
  body: string;
}

@Injectable()
export class PacksService {
  constructor(
    private readonly db: Database,
    private readonly validator: TaskValidator,
    private readonly audit: AuditService,
  ) {}

  /**
   * Собирает новый пакет из одобренных и уже опубликованных заданий.
   * Задание без текста на каком-либо языке пакета не пропускается.
   */
  async publish(staff: StaffUser, languages: string[] = ['ru']): Promise<PackSummary> {
    if (!languages.length || languages.some((l) => !(LANGUAGES as readonly string[]).includes(l))) {
      throw new UnprocessableEntityException({ message: 'Неизвестный язык пакета', errors: [] });
    }
    const version = await this.db.transaction(async (tx) => {
      const { rows } = await tx.query<{ id: string; body: TaskBody }>(
        `SELECT id, body FROM tasks WHERE status IN ('approved', 'published')
         ORDER BY id FOR UPDATE`,
      );
      if (!rows.length) throw new ConflictException('Нет одобренных заданий для выпуска');

      const errors: string[] = [];
      const tasks = rows.map(({ id, body }) => {
        const task: TaskBody = { ...body, review: { ...(body.review as object), status: 'published' } };
        errors.push(...this.validator.validate(task).map((e) => `${id}: ${e}`));
        const text = (task.instruction as { text?: Record<string, string> } | undefined)?.text ?? {};
        for (const lang of languages) {
          if (!text[lang]) errors.push(`${id}: нет текста инструкции на языке ${lang}`);
        }
        return task;
      });
      if (errors.length) throw new UnprocessableEntityException({ message: 'Пакет не собран', errors });

      const { rows: last } = await tx.query<{ max: number | null }>(
        'SELECT max(version) AS max FROM content_packs',
      );
      const version = (last[0]?.max ?? 0) + 1;
      const body = {
        packId: PACK_ID,
        packVersion: version,
        schemaVersion: 1,
        languages,
        publishedAt: new Date().toISOString(),
        tasks,
      };
      const text = JSON.stringify(body);
      const sha256 = createHash('sha256').update(text).digest('hex');
      await tx.query(
        `INSERT INTO content_packs (version, body, sha256, task_count, published_by)
         VALUES ($1, $2, $3, $4, $5)`,
        [version, text, sha256, tasks.length, staff.id],
      );
      await tx.query(
        `UPDATE tasks SET status = 'published',
                body = jsonb_set(body, '{review,status}', '"published"'), updated_at = now()
         WHERE status = 'approved'`,
      );
      await this.audit.record(staff.id, 'pack.publish', String(version), { tasks: tasks.length }, tx);
      return version;
    });
    return (await this.list()).find((p) => p.version === version)!;
  }

  list(): Promise<PackSummary[]> {
    return this.db.query<PackSummary>(
      `SELECT p.version, p.sha256, p.task_count AS "taskCount",
              p.published_at AS "publishedAt", u.name AS "publishedBy"
       FROM content_packs p JOIN staff_users u ON u.id = p.published_by
       ORDER BY p.version DESC`,
    );
  }

  /** Без [version] — последний выпущенный пакет. */
  async get(version?: number): Promise<PublishedPack> {
    const [row] = await this.db.query<PublishedPack>(
      version === undefined
        ? 'SELECT version, sha256, body FROM content_packs ORDER BY version DESC LIMIT 1'
        : 'SELECT version, sha256, body FROM content_packs WHERE version = $1',
      version === undefined ? [] : [version],
    );
    if (!row) throw new NotFoundException('Пакет не найден');
    return row;
  }
}
