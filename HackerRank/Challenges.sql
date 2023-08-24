with mq as (select h.hacker_id, h.name, count(c.challenge_id) c from hackers h
inner join challenges c on c.hacker_id=h.hacker_id
group by h.hacker_id, h.name),
exc as (select c, count(c) c1 from mq where c<(select max(c) from mq) group by c having count(c)>1)
select distinct mq.hacker_id, mq.name, mq.c from mq where mq.c not in (select c from exc)
order by mq.c desc, mq.hacker_id;