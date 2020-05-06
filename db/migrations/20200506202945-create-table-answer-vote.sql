-- up
create table answer_vote (
  id integer primary key,
  account_id integer not null references account(id),
  answer_id integer not null references answer(id),
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  unique (account_id, answer_id)
)

-- down
drop table answer_vote
