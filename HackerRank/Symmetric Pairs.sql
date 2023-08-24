WITH
    xy1 AS (SELECT x, y, x || y x_y, ROWNUM r1 FROM functions),
    xy2 AS (SELECT y || x y_x, ROWNUM r2 FROM functions)
  SELECT DISTINCT x, y
    FROM xy1 INNER JOIN xy2 ON x_y = y_x
   WHERE x <= y AND r1 != r2
ORDER BY x;