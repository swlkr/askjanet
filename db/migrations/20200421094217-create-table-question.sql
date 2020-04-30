-- up
create table question (
  id integer primary key,
  title text not null,
  body text,
  account_id integer not null references account(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table question
