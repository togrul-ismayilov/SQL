with max_sc as (select s.hacker_id, h.name, s.challenge_id, max(s.score) ms
from submissions s
inner join hackers h on h.hacker_id=s.hacker_id
group by s.hacker_id, s.challenge_id, h.name)
select * from
(select distinct hacker_id, name, sum(ms) over (partition by hacker_id) m from max_sc)
where m <>0
order by m desc, hacker_id;