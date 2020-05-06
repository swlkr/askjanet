select *
from (
  select answer.id, count(answer_vote.id) as votes
  from answer
  left outer join answer_vote on answer_vote.answer_id = answer.id
  group by answer.id
) a
join answer on answer.id = a.id
where
  answer.question_id = ?
order by votes desc, answer.created_at desc
