SELECT cnt.contest_id,
         cnt.hacker_id,
         cnt.name,
         SUM (ss.tot_sub),
         SUM (ss.tot_ac_sub),
         SUM (tot_v),
         SUM (tot_un_v)
    FROM contests cnt
         INNER JOIN colleges clg ON cnt.contest_id = clg.contest_id
         INNER JOIN challenges chl ON chl.college_id = clg.college_id
         LEFT JOIN
         (  SELECT challenge_id,
                   SUM (total_views)            tot_v,
                   SUM (total_unique_views)     tot_un_v
              FROM view_stats
          GROUP BY challenge_id) vs
             ON chl.challenge_id = vs.challenge_id
         LEFT JOIN
         (  SELECT challenge_id,
                   SUM (total_submissions)              tot_sub,
                   SUM (total_accepted_submissions)     tot_ac_sub
              FROM Submission_Stats
          GROUP BY challenge_id) ss
             ON ss.challenge_id = chl.challenge_id
GROUP BY cnt.contest_id, cnt.hacker_id, cnt.name
  HAVING (  NVL (SUM (ss.tot_sub), 0)
          + NVL (SUM (ss.tot_ac_sub), 0)
          + NVL (SUM (tot_v), 0)
          + NVL (SUM (tot_un_v), 0)) <>
         0
ORDER BY contest_id;