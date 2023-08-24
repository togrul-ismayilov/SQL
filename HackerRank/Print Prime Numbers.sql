WITH
    n
    AS
        (    SELECT LEVEL     l
               FROM DUAL
         CONNECT BY LEVEL <= 1000),
    n2
    AS
        (    SELECT LEVEL     l2
               FROM DUAL
         CONNECT BY LEVEL <= 1000),
    n_cross
    AS
        (SELECT l, l2
           FROM n CROSS JOIN n2)
SELECT LISTAGG (l, '&') WITHIN GROUP (ORDER BY l)
  FROM (  SELECT l
            FROM n_cross
           WHERE MOD (l, l2) = 0
        GROUP BY l
          HAVING COUNT (*) = 2);