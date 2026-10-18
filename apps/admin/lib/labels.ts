/** Подписи и правила интерфейса. Окончательно права проверяет сервер. */

export type Role = 'editor' | 'methodologist' | 'admin';
export type TaskStatus = 'draft' | 'in_review' | 'approved' | 'published' | 'withdrawn';
export type ReviewAction = 'submit' | 'approve' | 'reject' | 'withdraw';

export const STATUS_LABELS: Record<TaskStatus, string> = {
  draft: 'Черновик',
  in_review: 'На проверке',
  approved: 'Одобрено',
  published: 'Опубликовано',
  withdrawn: 'Снято',
};

export const ROLE_LABELS: Record<Role, string> = {
  editor: 'Редактор',
  methodologist: 'Методист',
  admin: 'Администратор',
};

export const ACTION_LABELS: Record<ReviewAction, string> = {
  submit: 'Отправить на проверку',
  approve: 'Одобрить',
  reject: 'Вернуть автору',
  withdraw: 'Снять с публикации',
};

export function canReview(role: Role): boolean {
  return role === 'methodologist' || role === 'admin';
}

/** Какие кнопки показать сотруднику для задания в этом статусе. */
export function availableActions(input: {
  role: Role;
  status: TaskStatus;
  isLastEditor: boolean;
}): ReviewAction[] {
  const actions: ReviewAction[] = [];
  if (input.status === 'draft') actions.push('submit');
  if (canReview(input.role)) {
    if (input.status === 'in_review') {
      if (!input.isLastEditor) actions.push('approve');
      actions.push('reject');
    }
    if (input.status !== 'withdrawn') actions.push('withdraw');
  }
  return actions;
}

export function isTaskStatus(value: unknown): value is TaskStatus {
  return typeof value === 'string' && Object.hasOwn(STATUS_LABELS, value);
}

const FIELD_ORDER = [
  'id',
  'schemaVersion',
  'version',
  'minAppVersion',
  'area',
  'goalId',
  'skills',
  'ageRange',
  'difficulty',
  'withParent',
  'exerciseType',
  'instruction',
  'content',
  'hints',
  'media',
  'reward',
  'review',
  'rights',
];

/** База хранит поля в своём порядке; в редакторе показываем их как в схеме. */
export function orderTaskFields(task: Record<string, unknown>): Record<string, unknown> {
  const rank = (key: string) => {
    const i = FIELD_ORDER.indexOf(key);
    return i === -1 ? FIELD_ORDER.length : i;
  };
  return Object.fromEntries(Object.entries(task).sort(([a], [b]) => rank(a) - rank(b)));
}

/** Заготовка нового задания: поля, которые всё равно придётся заполнить. */
export const TASK_TEMPLATE = {
  id: 'math.count.example.001',
  schemaVersion: 1,
  minAppVersion: '0.3.0',
  area: 'math',
  goalId: 'math.count_to_3',
  skills: ['counting'],
  ageRange: { minMonths: 36, maxMonths: 59 },
  difficulty: 1,
  withParent: false,
  exerciseType: 'choice',
  instruction: { text: { ru: 'Сколько яблок?' } },
  content: {
    options: [
      { id: 'n2', label: { ru: '2' } },
      { id: 'n3', label: { ru: '3' } },
    ],
    correct: ['n3'],
  },
  hints: [{ ru: 'Посчитай пальчиком.' }],
  media: [],
  reward: { stars: 3 },
  rights: [],
};
