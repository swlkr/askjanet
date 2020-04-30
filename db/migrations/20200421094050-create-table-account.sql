-- up
create table account (
  id integer primary key,
  name text unique not null,
  email text unique not null,
  code text,
  code_expires_at integer,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table account