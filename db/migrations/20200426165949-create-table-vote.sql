-- up
create table vote (
  id integer primary key,
  account_id integer not null references account(id),
  question_id integer not null references question(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  unique (account_id, question_id)
)

-- down
drop table vote
