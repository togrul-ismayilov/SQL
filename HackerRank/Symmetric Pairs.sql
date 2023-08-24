with xy1 as (select x,y, x||y x_y, rownum r1 from functions),
xy2 as (select y||x y_x, rownum r2 from functions)
select distinct x, y from xy1
inner join xy2 on x_y=y_x
where x<=y and r1!=r2
order by x;