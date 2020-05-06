CREATE TABLE schema_migrations (version text primary key)
CREATE TABLE account (
  id integer primary key,
  name text unique not null,
  email text unique not null,
  code text,
  code_expires_at integer,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
, deleted_at integer, dark_mode integer)
CREATE TABLE question (
  id integer primary key,
  title text not null,
  body text,
  account_id integer not null references account(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)
CREATE TABLE answer (
  id integer primary key,
  body text not null,
  question_id integer not null references question(id),
  account_id integer not null references account(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)
CREATE TABLE question_view (
  id integer primary key,
  account_id integer not null references account(id),
  question_id integer not null references question(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)
CREATE TABLE vote (
  id integer primary key,
  account_id integer not null references account(id),
  question_id integer not null references question(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  unique (account_id, question_id)
)
CREATE TABLE answer_vote (
  id integer primary key,
  account_id integer not null references account(id),
  answer_id integer not null references answer(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  unique (account_id, answer_id)
)