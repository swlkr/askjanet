-- up
drop table question_vote

-- down
create table question_vote (
  id integer primary key,
  account_id integer not null references account(id),
  question_id integer not null references question(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)
