'use client';

import { useActionState } from 'react';

import type { FormState } from './api';
import { checkTask, login, publishPack, reviewTask, saveTask } from './actions';
import { ACTION_LABELS, type ReviewAction } from './labels';

function Result({ state }: { state: FormState }) {
  if (!state.message) return null;
  return (
    <div className={state.ok ? 'notice ok' : 'notice error'} role="status">
      <p>{state.message}</p>
      {state.errors?.length ? (
        <ul>
          {state.errors.map((e) => (
            <li key={e}>{e}</li>
          ))}
        </ul>
      ) : null}
    </div>
  );
}

export function LoginForm() {
  const [state, action, pending] = useActionState(login, {});
  return (
    <form action={action} className="card narrow">
      <h1>Вход в редакцию</h1>
      <label>
        Почта
        <input name="email" type="email" autoComplete="username" required />
      </label>
      <label>
        Пароль
        <input name="password" type="password" autoComplete="current-password" required />
      </label>
      <button disabled={pending}>Войти</button>
      <Result state={state} />
    </form>
  );
}

export function TaskEditor(props: { id?: string; version?: number; json: string; readOnly?: boolean }) {
  const [saveState, save, saving] = useActionState(saveTask, {});
  const [checkState, check, checking] = useActionState(checkTask, {});
  return (
    <form className="card">
      <input type="hidden" name="id" value={props.id ?? ''} />
      <input type="hidden" name="expectedVersion" value={props.version ?? 0} />
      <label>
        Задание (JSON по схеме content/schema/task.schema.json)
        <textarea name="task" defaultValue={props.json} rows={28} spellCheck={false} readOnly={props.readOnly} />
      </label>
      {props.readOnly ? (
        <p className="muted">Задание на проверке: править его можно после возврата автору.</p>
      ) : (
        <div className="row">
          <button formAction={check} disabled={checking} className="secondary">
            Проверить
          </button>
          <button formAction={save} disabled={saving}>
            {props.id ? 'Сохранить новую версию' : 'Создать черновик'}
          </button>
        </div>
      )}
      <Result state={checkState} />
      <Result state={saveState} />
    </form>
  );
}

export function ReviewButtons(props: { id: string; version: number; actions: ReviewAction[] }) {
  const [state, action, pending] = useActionState(reviewTask, {});
  if (!props.actions.length) return null;
  // Отдельная форма на каждое действие: значение кнопки не зависит от браузера.
  return (
    <section className="card">
      <div className="row">
        {props.actions.map((a) => (
          <form key={a} action={action} className={a === 'reject' ? 'card' : undefined}>
            <input type="hidden" name="id" value={props.id} />
            <input type="hidden" name="expectedVersion" value={props.version} />
            <input type="hidden" name="action" value={a} />
            {a === 'reject' ? (
              <label>
                Что исправить автору
                <textarea name="notes" rows={3} required />
              </label>
            ) : null}
            <button disabled={pending} className={a === 'approve' || a === 'submit' ? '' : 'secondary'}>
              {ACTION_LABELS[a]}
            </button>
          </form>
        ))}
      </div>
      <Result state={state} />
    </section>
  );
}

export function PublishForm() {
  const [state, action, pending] = useActionState(publishPack, {});
  return (
    <form action={action} className="card">
      <h2>Выпустить новый пакет</h2>
      <p className="muted">
        В пакет войдут все одобренные и уже опубликованные задания. Приложение скачает его при следующем
        подключении к сети.
      </p>
      <fieldset className="row">
        <legend>Языки пакета</legend>
        <label className="inline">
          <input type="checkbox" name="languages" value="ru" defaultChecked /> русский
        </label>
        <label className="inline">
          <input type="checkbox" name="languages" value="uz" /> узбекский
        </label>
        <label className="inline">
          <input type="checkbox" name="languages" value="en" /> английский
        </label>
      </fieldset>
      <button disabled={pending}>Выпустить</button>
      <Result state={state} />
    </form>
  );
}
