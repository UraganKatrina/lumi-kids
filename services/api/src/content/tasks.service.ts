import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';

import { AuditService } from '../audit/audit.service';
import { Database, type Queryable } from '../db/database';
import type { StaffUser } from '../staff/staff';
import { canEdit, decideReview, type ReviewAction, type TaskStatus } from './review-policy';
import { TaskValidator } from './task-validator';

export type TaskBody = Record<string, unknown>;

export interface TaskSummary {
  id: string;
  version: number;
  status: TaskStatus;
  area: string;
  exerciseType: string;
  instruction: string;
  updatedAt: string;
  lastEditor: string;
}

export interface TaskDetails {
  id: string;
  version: number;
  status: TaskStatus;
  body: TaskBody;
  lastEditorId: string;
  reviewNotes: string | null;
  history: { version: number; createdAt: string; createdBy: string }[];
}

interface TaskRow {
  id: string;
  version: number;
  status: TaskStatus;
  body: TaskBody;
  last_editor_id: string;
  review_notes: string | null;
}

@Injectable()
export class TasksService {
  constructor(
    private readonly db: Database,
    private readonly validator: TaskValidator,
    private readonly audit: AuditService,
  ) {}

  /** Проверка без сохранения; поля, которые ставит сервер, подставляются так же. */
  validate(task: unknown): string[] {
    if (!isObject(task)) return ['/ нужен объект задания'];
    const version = Number.isInteger(task.version) ? task.version : 1;
    return this.validator.validate({ ...task, version, review: { status: 'draft' } });
  }

  async list(status?: TaskStatus): Promise<TaskSummary[]> {
    return this.db.query<TaskSummary>(
      `SELECT t.id, t.version, t.status,
              t.body->>'area' AS area,
              t.body->>'exerciseType' AS "exerciseType",
              t.body#>>'{instruction,text,ru}' AS instruction,
              t.updated_at AS "updatedAt",
              u.name AS "lastEditor"
       FROM tasks t JOIN staff_users u ON u.id = t.last_editor_id
       WHERE $1::text IS NULL OR t.status = $1
       ORDER BY t.updated_at DESC`,
      [status ?? null],
    );
  }

  async get(id: string): Promise<TaskDetails> {
    const row = await this.findRow(this.db.pool, id);
    const history = await this.db.query<TaskDetails['history'][number]>(
      `SELECT v.version, v.created_at AS "createdAt", u.name AS "createdBy"
       FROM task_versions v JOIN staff_users u ON u.id = v.created_by
       WHERE v.task_id = $1 ORDER BY v.version DESC`,
      [id],
    );
    return {
      id: row.id,
      version: row.version,
      status: row.status,
      body: row.body,
      lastEditorId: row.last_editor_id,
      reviewNotes: row.review_notes,
      history,
    };
  }

  async create(staff: StaffUser, task: unknown): Promise<TaskDetails> {
    const id = isObject(task) && typeof task.id === 'string' ? task.id : '';
    const body = this.prepare(task, id, 1);
    await this.db.transaction(async (tx) => {
      const exists = await tx.query('SELECT 1 FROM tasks WHERE id = $1', [id]);
      if (exists.rowCount) throw new ConflictException('Задание с таким id уже есть');
      await tx.query(
        `INSERT INTO tasks (id, version, status, body, last_editor_id)
         VALUES ($1, 1, 'draft', $2, $3)`,
        [id, body, staff.id],
      );
      await this.saveVersion(tx, id, 1, body, staff.id);
      await this.audit.record(staff.id, 'task.create', id, {}, tx);
    });
    return this.get(id);
  }

  /**
   * Новая версия задания. [expectedVersion] защищает от затирания чужой правки,
   * сделанной одновременно. Любая правка возвращает задание в черновики.
   */
  async update(staff: StaffUser, id: string, task: unknown, expectedVersion: number): Promise<TaskDetails> {
    await this.db.transaction(async (tx) => {
      const row = await this.findRow(tx, id, true);
      if (row.version !== expectedVersion) {
        throw new ConflictException('Задание уже изменил кто-то другой, обновите страницу');
      }
      if (!canEdit(row.status)) {
        throw new ConflictException('Задание на проверке: сначала его нужно вернуть автору');
      }
      const version = row.version + 1;
      const body = this.prepare(task, id, version);
      await tx.query(
        `UPDATE tasks SET version = $2, status = 'draft', body = $3, last_editor_id = $4,
                updated_at = now(), reviewed_by = NULL, reviewed_at = NULL, review_notes = NULL
         WHERE id = $1`,
        [id, version, body, staff.id],
      );
      await this.saveVersion(tx, id, version, body, staff.id);
      await this.audit.record(staff.id, 'task.update', id, { version }, tx);
    });
    return this.get(id);
  }

  async review(
    staff: StaffUser,
    id: string,
    action: ReviewAction,
    expectedVersion: number,
    notes?: string,
  ): Promise<TaskDetails> {
    await this.db.transaction(async (tx) => {
      const row = await this.findRow(tx, id, true);
      if (row.version !== expectedVersion) {
        throw new ConflictException('Задание изменилось, обновите страницу');
      }
      const decision = decideReview(action, {
        status: row.status,
        role: staff.role,
        actorId: staff.id,
        lastEditorId: row.last_editor_id,
        notes,
      });
      if (!decision.ok) throw new ForbiddenException(decision.reason);

      const body: TaskBody = { ...row.body, review: reviewBlock(decision.status, staff, notes) };
      if (decision.status === 'approved') {
        // Окончательная проверка перед одобрением: в пакет не попадёт неверное задание.
        const errors = this.validator.validate(body);
        if (errors.length) throw new UnprocessableEntityException({ message: 'Задание с ошибками', errors });
      }
      const reviewed = action === 'approve' || action === 'reject';
      await tx.query(
        `UPDATE tasks SET status = $2, body = $3, updated_at = now(),
                reviewed_by = CASE WHEN $4 THEN $5::uuid ELSE reviewed_by END,
                reviewed_at = CASE WHEN $4 THEN now() ELSE reviewed_at END,
                review_notes = $6
         WHERE id = $1`,
        [id, decision.status, body, reviewed, staff.id, notes?.trim() || null],
      );
      await this.audit.record(staff.id, `task.${action}`, id, { version: row.version }, tx);
    });
    return this.get(id);
  }

  /** Сервер сам ставит id, версию и статус: клиент не может их подделать. */
  private prepare(task: unknown, id: string, version: number): TaskBody {
    if (!isObject(task)) throw new UnprocessableEntityException({ message: 'Нужен объект задания', errors: [] });
    const body: TaskBody = { ...task, id, version, review: { status: 'draft' } };
    const errors = this.validator.validate(body);
    if (errors.length) throw new UnprocessableEntityException({ message: 'Задание с ошибками', errors });
    return body;
  }

  private async findRow(tx: Queryable, id: string, lock = false): Promise<TaskRow> {
    const result = await tx.query<TaskRow>(
      `SELECT id, version, status, body, last_editor_id, review_notes FROM tasks WHERE id = $1
       ${lock ? 'FOR UPDATE' : ''}`,
      [id],
    );
    const row = result.rows[0];
    if (!row) throw new NotFoundException('Задание не найдено');
    return row;
  }

  private async saveVersion(tx: Queryable, id: string, version: number, body: TaskBody, staffId: string) {
    await tx.query(
      'INSERT INTO task_versions (task_id, version, body, created_by) VALUES ($1, $2, $3, $4)',
      [id, version, body, staffId],
    );
  }
}

function reviewBlock(status: TaskStatus, staff: StaffUser, notes?: string): TaskBody {
  if (status === 'approved' || status === 'published') {
    // В пакет уходит id сотрудника, а не почта и не имя.
    return { status, reviewedBy: `staff:${staff.id}`, reviewedAt: new Date().toISOString() };
  }
  return notes?.trim() ? { status, notes: notes.trim() } : { status };
}

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}
