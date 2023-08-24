select hacker_id, name from (select 
h.hacker_id ,
h.name,
sum(case when s.score=d.score then 1 else 0 end) Full_score_cnt
from submissions s
inner join challenges c on c.challenge_id=s.challenge_id
inner join Difficulty d on c.difficulty_level=d.difficulty_level
inner join Hackers h on s.hacker_id=h.hacker_id
having sum(case when s.score=d.score then 1 else 0 end)>1
group by 
h.hacker_id,
h.name
order by Full_score_cnt desc, hacker_id);