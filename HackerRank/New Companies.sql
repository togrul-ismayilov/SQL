select 
c.company_code,
c.founder,
count(distinct l.lead_manager_code),
count(distinct s.senior_manager_code),
count(distinct m.manager_code),
count(distinct e.employee_code)
from company c
join  Lead_Manager l on c.company_code=l.company_code
join Senior_Manager s on c.company_code=s.company_code and s.lead_manager_code=l.lead_manager_code
join Manager m on  c.company_code=m.company_code and m.lead_manager_code=s.lead_manager_code and m.senior_manager_code= s.senior_manager_code
join Employee e on c.company_code=e.company_code and e.lead_manager_code=m.lead_manager_code and e.senior_manager_code= m.senior_manager_code and m.manager_code=e.manager_code
group by 
c.company_code,
c.founder
order by c.company_code;