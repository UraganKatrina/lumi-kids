import { ConflictException, UnprocessableEntityException } from '@nestjs/common';

import type { StaffUser } from '../staff/staff';
import type { TasksService } from './tasks.service';

export interface ImportReport {
  created: string[];
  skipped: string[];
  failed: { id: string; errors: string[] }[];
}

/**
 * Загружает задания из пакета как черновики. Уже существующие пропускаются:
 * импорт можно запускать повторно. Каждое задание дальше проходит обычную
 * проверку методистом — импорт ничего не публикует.
 */
export async function importTasks(
  tasks: TasksService,
  staff: StaffUser,
  items: unknown[],
): Promise<ImportReport> {
  const report: ImportReport = { created: [], skipped: [], failed: [] };
  for (const item of items) {
    const id = String((item as { id?: unknown })?.id ?? '?');
    try {
      await tasks.create(staff, item);
      report.created.push(id);
    } catch (error) {
      if (error instanceof ConflictException) {
        report.skipped.push(id);
      } else if (error instanceof UnprocessableEntityException) {
        const body = error.getResponse() as { errors?: string[] };
        report.failed.push({ id, errors: body.errors ?? [] });
      } else {
        throw error;
      }
    }
  }
  return report;
}
