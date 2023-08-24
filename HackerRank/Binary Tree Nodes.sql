WITH
    hl
    AS
        (    SELECT bst.*, LEVEL l
               FROM BST
         START WITH p IS NULL
         CONNECT BY PRIOR n = p)
  SELECT n,
         (CASE
              WHEN l = (SELECT MAX (l) FROM hl) THEN 'Leaf'
              WHEN l = 1 THEN 'Root'
              ELSE 'Inner'
          END)
    FROM hl
ORDER BY 1;