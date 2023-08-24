select case when  g.grade>=8 then s.name else 'NULL' end, 
g.grade, s.marks from students s
inner join grades g on s.marks>=g.min_mark and s.marks<=g.max_mark
order by g.grade desc, s.name, s.marks;