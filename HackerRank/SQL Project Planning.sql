with dates as (select 
end_date,
start_date,
nvl(end_date-lag(end_date) over (order by end_date),2) lg,
nvl(lead(end_date) over (order by end_date)-end_date,2) ld
from projects p)
select 
start_date,
end_date
from
(select 
start_date,
case when end_date is null then lead(end_date) over (order by r) else end_date end end_date
from (select rownum r,
case when (ld=1 and lg<>1) or (ld<>1 and lg<>1) then start_date end as start_date,
case when (ld<>1 and lg=1) or (ld<>1 and lg<>1) then end_date end as end_date
from dates)
where start_date is not null or end_date is not null)
where start_date is not null
order by end_date-start_date,1;