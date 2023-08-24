select s.name
from Students s
inner join Friends f on s.id=f.id
inner join Packages p on s.id=p.id
where p.salary<(select p2.salary from Packages p2 where p2.id=f.friend_id)
order by (select p2.salary from Packages p2 where p2.id=f.friend_id);