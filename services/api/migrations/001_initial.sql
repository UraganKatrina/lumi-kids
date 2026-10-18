-- Сотрудники редакции: редакторы пишут задания, методисты их проверяют.
CREATE TABLE staff_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL UNIQUE,
  name text NOT NULL,
  role text NOT NULL CHECK (role IN ('editor', 'methodologist', 'admin')),
  password_hash text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  disabled_at timestamptz
);

-- В базе хранится только хэш токена: утечка таблицы не даёт войти.
CREATE TABLE staff_sessions (
  token_hash text PRIMARY KEY,
  staff_id uuid NOT NULL REFERENCES staff_users (id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL
);
CREATE INDEX staff_sessions_staff_idx ON staff_sessions (staff_id);

-- Текущее состояние задания.
CREATE TABLE tasks (
  id text PRIMARY KEY,
  version integer NOT NULL,
  status text NOT NULL CHECK (status IN ('draft', 'in_review', 'approved', 'published', 'withdrawn')),
  body jsonb NOT NULL,
  last_editor_id uuid NOT NULL REFERENCES staff_users (id),
  updated_at timestamptz NOT NULL DEFAULT now(),
  reviewed_by uuid REFERENCES staff_users (id),
  reviewed_at timestamptz,
  review_notes text
);
CREATE INDEX tasks_status_idx ON tasks (status);

-- Каждая сохранённая версия задания: история правок не теряется.
CREATE TABLE task_versions (
  task_id text NOT NULL REFERENCES tasks (id),
  version integer NOT NULL,
  body jsonb NOT NULL,
  created_by uuid NOT NULL REFERENCES staff_users (id),
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (task_id, version)
);

-- Выпущенные пакеты не меняются; приложение скачивает их целиком.
-- Текст хранится как есть (не jsonb), чтобы хэш совпадал байт в байт.
CREATE TABLE content_packs (
  version integer PRIMARY KEY,
  body text NOT NULL,
  sha256 text NOT NULL,
  task_count integer NOT NULL,
  published_by uuid NOT NULL REFERENCES staff_users (id),
  published_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE audit_log (
  id bigserial PRIMARY KEY,
  actor_id uuid REFERENCES staff_users (id),
  action text NOT NULL,
  target text,
  details jsonb,
  at timestamptz NOT NULL DEFAULT now()
);
