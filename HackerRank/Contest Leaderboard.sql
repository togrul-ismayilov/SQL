WITH
    max_sc
    AS
        (  SELECT s.hacker_id,
                  h.name,
                  s.challenge_id,
                  MAX (s.score)     ms
             FROM submissions s
                  INNER JOIN hackers h ON h.hacker_id = s.hacker_id
         GROUP BY s.hacker_id, s.challenge_id, h.name)
  SELECT *
    FROM (SELECT DISTINCT
                 hacker_id, name, SUM (ms) OVER (PARTITION BY hacker_id) m
            FROM max_sc)
   WHERE m <> 0
ORDER BY m DESC, hacker_id;