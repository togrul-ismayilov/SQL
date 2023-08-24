SELECT CASE WHEN g.grade >= 8 THEN s.name ELSE 'NULL' END, g.grade, s.marks
    FROM students s
         INNER JOIN grades g ON s.marks >= g.min_mark AND s.marks <= g.max_mark
ORDER BY g.grade DESC, s.name, s.marks;