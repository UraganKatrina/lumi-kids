import type { Role } from '../staff/staff';

export const STATUSES = ['draft', 'in_review', 'approved', 'published', 'withdrawn'] as const;
export type TaskStatus = (typeof STATUSES)[number];

export const REVIEW_ACTIONS = ['submit', 'approve', 'reject', 'withdraw'] as const;
export type ReviewAction = (typeof REVIEW_ACTIONS)[number];

const REVIEWERS: readonly Role[] = ['methodologist', 'admin'];

export interface ReviewContext {
  status: TaskStatus;
  role: Role;
  actorId: string;
  lastEditorId: string;
  notes?: string;
}

export type ReviewDecision = { ok: true; status: TaskStatus } | { ok: false; reason: string };

/**
 * Правила проверки контента. Задание попадает к детям только после одобрения
 * методистом, и одобрить его может только другой человек, а не автор правки.
 */
export function decideReview(action: ReviewAction, ctx: ReviewContext): ReviewDecision {
  const deny = (reason: string): ReviewDecision => ({ ok: false, reason });
  const isReviewer = REVIEWERS.includes(ctx.role);
  switch (action) {
    case 'submit':
      return ctx.status === 'draft'
        ? { ok: true, status: 'in_review' }
        : deny('На проверку отправляется только черновик');
    case 'approve':
      if (!isReviewer) return deny('Одобрять задания может только методист');
      if (ctx.status !== 'in_review') return deny('Одобрить можно только задание на проверке');
      if (ctx.actorId === ctx.lastEditorId) {
        return deny('Нельзя одобрить свою же правку: нужен второй человек');
      }
      return { ok: true, status: 'approved' };
    case 'reject':
      if (!isReviewer) return deny('Возвращать задания может только методист');
      if (ctx.status !== 'in_review') return deny('Вернуть можно только задание на проверке');
      if (!ctx.notes?.trim()) return deny('Напишите, что исправить');
      return { ok: true, status: 'draft' };
    case 'withdraw':
      if (!isReviewer) return deny('Снимать задания может только методист');
      if (ctx.status === 'withdrawn') return deny('Задание уже снято');
      return { ok: true, status: 'withdrawn' };
  }
}

/** Правка задания на проверке запрещена: сначала его нужно вернуть автору. */
export function canEdit(status: TaskStatus): boolean {
  return status !== 'in_review';
}
