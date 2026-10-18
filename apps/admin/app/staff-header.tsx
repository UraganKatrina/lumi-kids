import Link from 'next/link';

import { logout } from '@/lib/actions';
import type { Staff } from '@/lib/api';
import { ROLE_LABELS } from '@/lib/labels';

export function StaffHeader({ staff }: { staff: Staff }) {
  return (
    <header className="top">
      <Link href="/" className="brand">
        LUMI Kids · редакция
      </Link>
      <nav>
        <Link href="/">Задания</Link>
        <Link href="/packs">Пакеты</Link>
      </nav>
      <span className="muted">
        {staff.name} · {ROLE_LABELS[staff.role]}
      </span>
      <form action={logout}>
        <button className="secondary">Выйти</button>
      </form>
    </header>
  );
}
