select w2.id, ww.age, ww.mc, ww.mp from (select 
w.code,
wp.age, 
min(w.coins_needed) mc, 
w.power mp
from Wands w 
inner join Wands_Property wp on wp.code = w.code 
where is_evil = 0 
group by w.code, wp.age, w.power) ww
inner join wands w2 on ww.code=w2.code and ww.mc=w2.coins_needed and ww.mp=w2.power
order by ww.mp desc, ww.age desc;
