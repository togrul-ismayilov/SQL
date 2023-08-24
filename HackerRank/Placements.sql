SELECT s.name
    FROM Students s
         INNER JOIN Friends f ON s.id = f.id
         INNER JOIN Packages p ON s.id = p.id
   WHERE p.salary < (SELECT p2.salary
                       FROM Packages p2
                      WHERE p2.id = f.friend_id)
ORDER BY (SELECT p2.salary
            FROM Packages p2
           WHERE p2.id = f.friend_id);