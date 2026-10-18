import { api, requireStaff, type PackSummary } from '@/lib/api';
import { PublishForm } from '@/lib/forms';
import { canReview } from '@/lib/labels';

import { StaffHeader } from '../staff-header';

export default async function PacksPage() {
  const staff = await requireStaff();
  const packs = await api<PackSummary[]>('/v1/admin/packs');
  return (
    <>
      <StaffHeader staff={staff} />
      <main>
        <h1>Пакеты контента</h1>
        {canReview(staff.role) ? (
          <PublishForm />
        ) : (
          <p className="muted">Выпускать пакеты могут методисты и администраторы.</p>
        )}
        {packs.length === 0 ? (
          <p className="muted">Пакетов ещё не выпускали.</p>
        ) : (
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>№</th>
                  <th>Заданий</th>
                  <th>Выпустил</th>
                  <th>Когда</th>
                  <th>SHA-256</th>
                </tr>
              </thead>
              <tbody>
                {packs.map((p) => (
                  <tr key={p.version}>
                    <td>{p.version}</td>
                    <td>{p.taskCount}</td>
                    <td>{p.publishedBy}</td>
                    <td>{new Date(p.publishedAt).toLocaleString('ru-RU')}</td>
                    <td className="muted">{p.sha256.slice(0, 12)}…</td>
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
