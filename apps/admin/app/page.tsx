import Link from 'next/link';

import { api, requireStaff, type TaskSummary } from '@/lib/api';
import { isTaskStatus, STATUS_LABELS, type TaskStatus } from '@/lib/labels';

import { StaffHeader } from './staff-header';

export default async function TasksPage({ searchParams }: { searchParams: Promise<{ status?: string }> }) {
  const staff = await requireStaff();
  const { status } = await searchParams;
  const filter = isTaskStatus(status) ? status : undefined;
  const tasks = await api<TaskSummary[]>(`/v1/admin/tasks${filter ? `?status=${filter}` : ''}`);

  return (
    <>
      <StaffHeader staff={staff} />
      <main>
        <div className="row" style={{ justifyContent: 'space-between' }}>
          <h1>Задания</h1>
          <Link href="/tasks/new">
            <button>Новое задание</button>
          </Link>
        </div>
        <div className="filters">
          <Link href="/" className={filter ? '' : 'active'}>
            Все
          </Link>
          {(Object.keys(STATUS_LABELS) as TaskStatus[]).map((s) => (
            <Link key={s} href={`/?status=${s}`} className={filter === s ? 'active' : ''}>
              {STATUS_LABELS[s]}
            </Link>
          ))}
        </div>
        {tasks.length === 0 ? (
          <p className="muted">Заданий пока нет.</p>
        ) : (
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Задание</th>
                  <th>Направление</th>
                  <th>Статус</th>
                  <th>Версия</th>
                  <th>Правил</th>
                </tr>
              </thead>
              <tbody>
                {tasks.map((t) => (
                  <tr key={t.id}>
                    <td>
                      <Link href={`/tasks/${encodeURIComponent(t.id)}`}>{t.instruction ?? t.id}</Link>
                      <div className="muted">{t.id}</div>
                    </td>
                    <td>
                      {t.area}
                      <div className="muted">{t.exerciseType}</div>
                    </td>
                    <td>
                      <span className={`badge ${t.status}`}>{STATUS_LABELS[t.status]}</span>
                    </td>
                    <td>{t.version}</td>
                    <td>{t.lastEditor}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </main>
    </>
  );
}
