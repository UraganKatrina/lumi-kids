import { notFound } from 'next/navigation';

import { api, ApiError, requireStaff, type TaskDetails } from '@/lib/api';
import { ReviewButtons, TaskEditor } from '@/lib/forms';
import { availableActions, canReview, orderTaskFields, STATUS_LABELS } from '@/lib/labels';

import { StaffHeader } from '../../staff-header';

export default async function TaskPage({ params }: { params: Promise<{ id: string }> }) {
  const staff = await requireStaff();
  const { id } = await params;
  let task: TaskDetails;
  try {
    task = await api<TaskDetails>(`/v1/admin/tasks/${encodeURIComponent(id)}`);
  } catch (error) {
    if (error instanceof ApiError && error.status === 404) notFound();
    throw error;
  }
  const actions = availableActions({
    role: staff.role,
    status: task.status,
    isLastEditor: task.lastEditorId === staff.id,
  });

  return (
    <>
      <StaffHeader staff={staff} />
      <main>
        <h1>{task.id}</h1>
        <div className="row">
          <span className={`badge ${task.status}`}>{STATUS_LABELS[task.status]}</span>
          <span className="muted">версия {task.version}</span>
        </div>
        {task.reviewNotes ? (
          <div className="notice error">
            <p>Комментарий методиста: {task.reviewNotes}</p>
          </div>
        ) : null}
        {task.status === 'in_review' && task.lastEditorId === staff.id && canReview(staff.role) ? (
          <p className="muted">Это ваша правка: одобрить её должен другой методист.</p>
        ) : null}
        <ReviewButtons key={`${task.version}-${task.status}`} id={task.id} version={task.version} actions={actions} />
        <TaskEditor
          key={task.version}
          id={task.id}
          version={task.version}
          json={JSON.stringify(orderTaskFields(task.body), null, 2)}
          readOnly={task.status === 'in_review'}
        />
        <section className="card">
          <h2>История версий</h2>
          <ul>
            {task.history.map((h) => (
              <li key={h.version}>
                версия {h.version} — {h.createdBy}, {new Date(h.createdAt).toLocaleString('ru-RU')}
              </li>
            ))}
          </ul>
        </section>
      </main>
    </>
  );
}
