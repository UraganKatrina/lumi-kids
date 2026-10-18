import 'server-only';

import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';

import type { Role, TaskStatus } from './labels';

export const SESSION_COOKIE = 'lumi_admin';

/** Адрес API знает только сервер админки; в браузер он не попадает. */
const API_URL = process.env.API_URL ?? 'http://127.0.0.1:3000';

export class ApiError extends Error {
  constructor(
    readonly status: number,
    message: string,
    readonly errors: string[] = [],
  ) {
    super(message);
  }
}

export interface Staff {
  id: string;
  email: string;
  name: string;
  role: Role;
}

export interface TaskSummary {
  id: string;
  version: number;
  status: TaskStatus;
  area: string;
  exerciseType: string;
  instruction: string | null;
  updatedAt: string;
  lastEditor: string;
}

export interface TaskDetails {
  id: string;
  version: number;
  status: TaskStatus;
  body: Record<string, unknown>;
  lastEditorId: string;
  reviewNotes: string | null;
  history: { version: number; createdAt: string; createdBy: string }[];
}

export interface PackSummary {
  version: number;
  sha256: string;
  taskCount: number;
  publishedAt: string;
  publishedBy: string;
}

export async function api<T>(path: string, init: { method?: string; body?: unknown; token?: string } = {}): Promise<T> {
  const token = init.token ?? (await cookies()).get(SESSION_COOKIE)?.value;
  const response = await fetch(`${API_URL}${path}`, {
    method: init.method ?? 'GET',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: init.body === undefined ? undefined : JSON.stringify(init.body),
    cache: 'no-store',
  });
  if (response.status === 204) return undefined as T;
  const data = await response.json().catch(() => ({}));
  if (!response.ok) {
    const message = typeof data.message === 'string' ? data.message : `Ошибка ${response.status}`;
    throw new ApiError(response.status, message, Array.isArray(data.errors) ? data.errors : []);
  }
  return data as T;
}

/** Текущий сотрудник; без входа — на страницу входа. */
export async function requireStaff(): Promise<Staff> {
  try {
    return await api<Staff>('/v1/admin/me');
  } catch (error) {
    if (error instanceof ApiError && error.status === 401) redirect('/login');
    throw error;
  }
}

export type FormState = { ok?: boolean; message?: string; errors?: string[] };

export function toFormState(error: unknown): FormState {
  if (error instanceof ApiError) return { message: error.message, errors: error.errors };
  throw error;
}
