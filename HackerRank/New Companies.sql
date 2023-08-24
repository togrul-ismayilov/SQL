SELECT c.company_code,
         c.founder,
         COUNT (DISTINCT l.lead_manager_code),
         COUNT (DISTINCT s.senior_manager_code),
         COUNT (DISTINCT m.manager_code),
         COUNT (DISTINCT e.employee_code)
    FROM company c
         JOIN Lead_Manager l ON c.company_code = l.company_code
         JOIN Senior_Manager s
             ON     c.company_code = s.company_code
                AND s.lead_manager_code = l.lead_manager_code
         JOIN Manager m
             ON     c.company_code = m.company_code
                AND m.lead_manager_code = s.lead_manager_code
                AND m.senior_manager_code = s.senior_manager_code
         JOIN Employee e
             ON     c.company_code = e.company_code
                AND e.lead_manager_code = m.lead_manager_code
                AND e.senior_manager_code = m.senior_manager_code
                AND m.manager_code = e.manager_code
GROUP BY c.company_code, c.founder
ORDER BY c.company_code;