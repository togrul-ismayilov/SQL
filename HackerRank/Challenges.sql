WITH
    mq
    AS
        (  SELECT h.hacker_id, h.name, COUNT (c.challenge_id) c
             FROM hackers h
                  INNER JOIN challenges c ON c.hacker_id = h.hacker_id
         GROUP BY h.hacker_id, h.name),
    exc
    AS
        (  SELECT c, COUNT (c) c1
             FROM mq
            WHERE c < (SELECT MAX (c) FROM mq)
         GROUP BY c
           HAVING COUNT (c) > 1)
  SELECT DISTINCT mq.hacker_id, mq.name, mq.c
    FROM mq
   WHERE mq.c NOT IN (SELECT c FROM exc)
ORDER BY mq.c DESC, mq.hacker_id;