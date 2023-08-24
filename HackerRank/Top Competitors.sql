SELECT hacker_id, name
  FROM (  SELECT h.hacker_id,
                 h.name,
                 SUM (CASE WHEN s.score = d.score THEN 1 ELSE 0 END)    Full_score_cnt
            FROM submissions s
                 INNER JOIN challenges c ON c.challenge_id = s.challenge_id
                 INNER JOIN Difficulty d
                     ON c.difficulty_level = d.difficulty_level
                 INNER JOIN Hackers h ON s.hacker_id = h.hacker_id
          HAVING SUM (CASE WHEN s.score = d.score THEN 1 ELSE 0 END) > 1
        GROUP BY h.hacker_id, h.name
        ORDER BY Full_score_cnt DESC, hacker_id);