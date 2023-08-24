SELECT w2.id,
         ww.age,
         ww.mc,
         ww.mp
    FROM (  SELECT w.code,
                   wp.age,
                   MIN (w.coins_needed)     mc,
                   w.POWER                  mp
              FROM Wands w INNER JOIN Wands_Property wp ON wp.code = w.code
             WHERE is_evil = 0
          GROUP BY w.code, wp.age, w.POWER) ww
         INNER JOIN wands w2
             ON     ww.code = w2.code
                AND ww.mc = w2.coins_needed
                AND ww.mp = w2.POWER
ORDER BY ww.mp DESC, ww.age DESC;