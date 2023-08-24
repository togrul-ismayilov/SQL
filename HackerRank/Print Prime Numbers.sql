with n as (select level l from dual
connect by level<=1000),
 n2 as (select level l2 from dual
connect by level<=1000),
n_cross as (select l,l2 from n
cross join n2)
select 
listagg(l,'&') within group (order by l)
from (select l from n_cross
where mod(l,l2)=0
group by l
having count(*)=2);