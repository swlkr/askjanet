select question.id, question.title, account.email
from question
join answer on answer.question_id = question.id
join account on account.id = question.account_id
where
    answer.created_at > ?
  and
    account.deleted_at is null
  and
    account.daily_summary = 1
