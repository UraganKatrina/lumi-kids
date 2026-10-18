'use server';

import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';
import { revalidatePath } from 'next/cache';

import { api, SESSION_COOKIE, toFormState, type FormState, type PackSummary, type TaskDetails } from './api';

export async function login(_: FormState, form: FormData): Promise<FormState> {
  try {
    const { token } = await api<{ token: string }>('/v1/admin/login', {
      method: 'POST',
      body: { email: String(form.get('email') ?? ''), password: String(form.get('password') ?? '') },
    });
    (await cookies()).set(SESSION_COOKIE, token, {
      httpOnly: true,
      sameSite: 'strict',
      secure: process.env.NODE_ENV === 'production',
      path: '/',
      maxAge: 12 * 60 * 60,
    });
  } catch (error) {
    return toFormState(error);
  }
  redirect('/');
}

export async function logout(): Promise<void> {
  try {
    await api('/v1/admin/logout', { method: 'POST' });
  } catch {
    // Сессия могла уже истечь: cookie удаляем в любом случае.
  }
  (await cookies()).delete(SESSION_COOKIE);
  redirect('/login');
}

function parseTask(form: FormData): unknown {
  return JSON.parse(String(form.get('task') ?? ''));
}

export async function saveTask(_: FormState, form: FormData): Promise<FormState> {
  const id = String(form.get('id') ?? '');
  let saved: TaskDetails;
  try {
    let task: unknown;
    try {
      task = parseTask(form);
    } catch {
      return { message: 'Это не JSON: проверьте скобки и кавычки' };
    }
    saved = id
      ? await api<TaskDetails>(`/v1/admin/tasks/${encodeURIComponent(id)}`, {
          method: 'PUT',
          body: { task, expectedVersion: Number(form.get('expectedVersion')) },
        })
      : await api<TaskDetails>('/v1/admin/tasks', { method: 'POST', body: { task } });
  } catch (error) {
    return toFormState(error);
  }
  revalidatePath('/');
  redirect(`/tasks/${encodeURIComponent(saved.id)}`);
}

export async function checkTask(_: FormState, form: FormData): Promise<FormState> {
  let task: unknown;
  try {
    task = parseTask(form);
  } catch {
    return { message: 'Это не JSON: проверьте скобки и кавычки' };
  }
  try {
    const { errors } = await api<{ errors: string[] }>('/v1/admin/tasks/validate', { method: 'POST', body: { task } });
    return errors.length ? { message: 'Есть ошибки', errors } : { ok: true, message: 'Ошибок нет' };
  } catch (error) {
    return toFormState(error);
  }
}

export async function reviewTask(_: FormState, form: FormData): Promise<FormState> {
  const id = String(form.get('id') ?? '');
  try {
    await api(`/v1/admin/tasks/${encodeURIComponent(id)}/review`, {
      method: 'POST',
      body: {
        action: String(form.get('action') ?? ''),
        notes: String(form.get('notes') ?? '') || undefined,
        expectedVersion: Number(form.get('expectedVersion')),
      },
    });
  } catch (error) {
    return toFormState(error);
  }
  revalidatePath(`/tasks/${id}`);
  return { ok: true, message: 'Готово' };
}

export async function publishPack(_: FormState, form: FormData): Promise<FormState> {
  const languages = form.getAll('languages').map(String);
  try {
    const pack = await api<PackSummary>('/v1/admin/packs', { method: 'POST', body: { languages } });
    revalidatePath('/packs');
    return { ok: true, message: `Выпущен пакет №${pack.version}: заданий ${pack.taskCount}` };
  } catch (error) {
    return toFormState(error);
  }
}
