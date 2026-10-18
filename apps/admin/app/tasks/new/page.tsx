import { requireStaff } from '@/lib/api';
import { TaskEditor } from '@/lib/forms';
import { TASK_TEMPLATE } from '@/lib/labels';

import { StaffHeader } from '../../staff-header';

export default async function NewTaskPage() {
  const staff = await requireStaff();
  return (
    <>
      <StaffHeader staff={staff} />
      <main>
        <h1>Новое задание</h1>
        <p className="muted">
          Задание сохраняется как черновик. К детям оно попадёт только после одобрения методистом и выпуска
          пакета.
        </p>
        <TaskEditor json={JSON.stringify(TASK_TEMPLATE, null, 2)} />
      </main>
    </>
  );
}
