with hl as (select bst.*, level l
from BST
start with p is null
connect by prior n=p)
select n, 
(case when l=(select max(l) from hl) then 'Leaf'
when l=1 then 'Root'
else 'Inner' end)
from hl order by 1;