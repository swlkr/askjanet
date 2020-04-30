-- up
create table answer (
  id integer primary key,
  body text not null,
  question_id integer not null references question(id),
  account_id integer not null references account(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table answer