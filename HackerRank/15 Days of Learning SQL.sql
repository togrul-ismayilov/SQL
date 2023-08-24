WITH unique_subs AS
        (SELECT submission_date, COUNT (DISTINCT hacker_id) unique_hackers
             FROM (SELECT submission_date,
                          hacker_id,
                          sub_day,
                          ROW_NUMBER () OVER (PARTITION BY hacker_id ORDER BY submission_date)    sub_count
                     FROM (SELECT DISTINCT
                                    submission_date,
                                    hacker_id,
                                    TO_NUMBER (TO_CHAR (submission_date, 'dd'))    sub_day
                               FROM submissions
                           ORDER BY submission_date))
            WHERE     sub_count >= sub_day
                  AND submission_date BETWEEN TO_DATE ('01.03.2016','dd.mm.yyyy')
                                          AND TO_DATE ('15.03.2016','dd.mm.yyyy')
         GROUP BY submission_date),
    max_subs
    AS
        (SELECT DISTINCT
                FIRST_VALUE (hacker_id) OVER (PARTITION BY submission_date ORDER BY cnt DESC) max_hacker_id,
                submission_date
           FROM (SELECT submission_date,
                          hacker_id,
                          DENSE_RANK () OVER (PARTITION BY submission_date ORDER BY COUNT (hacker_id)) cnt
                     FROM submissions
                 GROUP BY submission_date, hacker_id))
  SELECT DISTINCT s.submission_date,
                  u.unique_hackers,
                  m.max_hacker_id,
                  h.name
    FROM submissions s
         INNER JOIN unique_subs u ON  u.submission_date = s.submission_date
         INNER JOIN max_subs    m ON  m.submission_date = s.submission_date AND m.max_hacker_id = s.hacker_id
         INNER JOIN hackers     h ON  h.hacker_id = m.max_hacker_id
ORDER BY s.submission_date;