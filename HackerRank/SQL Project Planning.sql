WITH
    dates
    AS
        (SELECT end_date,
                start_date,
                NVL (end_date - LAG (end_date) OVER (ORDER BY end_date), 2)
                    lg,
                NVL (LEAD (end_date) OVER (ORDER BY end_date) - end_date, 2)
                    ld
           FROM projects p)
  SELECT start_date, end_date
    FROM (SELECT start_date,
                 CASE
                     WHEN end_date IS NULL
                     THEN
                         LEAD (end_date) OVER (ORDER BY r)
                     ELSE
                         end_date
                 END    end_date
            FROM (SELECT ROWNUM    r,
                         CASE
                             WHEN (ld = 1 AND lg <> 1) OR (ld <> 1 AND lg <> 1)
                             THEN
                                 start_date
                         END       AS start_date,
                         CASE
                             WHEN (ld <> 1 AND lg = 1) OR (ld <> 1 AND lg <> 1)
                             THEN
                                 end_date
                         END       AS end_date
                    FROM dates)
           WHERE start_date IS NOT NULL OR end_date IS NOT NULL)
   WHERE start_date IS NOT NULL
ORDER BY end_date - start_date, 1;