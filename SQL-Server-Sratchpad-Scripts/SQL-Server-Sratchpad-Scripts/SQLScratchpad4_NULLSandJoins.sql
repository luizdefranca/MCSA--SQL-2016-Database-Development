DROP TABLE IF EXISTS dbo.my_nullTable1;
DROP TABLE IF EXISTS dbo.my_nullTable2;

SELECT *
  INTO dbo.my_nullTable1
  FROM (
    VALUES(1, 'one'),(null, 'two'), (3, null), (null, 'four')
  ) t1(col1, col2);

SELECT *
  INTO dbo.my_nullTable2
  FROM (
    VALUES(1, 'one'),(2, null), (null, 'three'), (null, 'four')
  ) t1(col1, col2);

SELECT t1.col1  AS t1_col1,
       t2.col1  AS t2_col2
  FROM dbo.my_nullTable1 AS t1
  JOIN dbo.my_nullTable2 AS t2
    ON t1.col1 <> t2.col1  --NOT(t1.col1 = t2.col1)
 ORDER BY t1.col1 ASC;

SELECT t1.col1  AS t1_col1,
       t1.col2  AS t1_col2,
       t2.col1  AS t2_col2,
       t2.col1  AS t2_col2
  FROM dbo.my_nullTable1 AS t1
  LEFT JOIN dbo.my_nullTable2 AS t2
    ON t1.col1 = t2.col1  
 ORDER BY t1.col1 ASC;

SELECT t1.col1  AS t1_col1,
       t1.col2  AS t1_col2,
       t2.col1  AS t2_col2,
       t2.col1  AS t2_col2
  FROM dbo.my_nullTable1 AS t1
  JOIN dbo.my_nullTable2 AS t2
    ON t1.col1 <> CASE WHEN t2.col1 IS NULL THEN -1 ELSE t2.col1 END
 ORDER BY t1.col1 ASC;

SELECT t1.col1  AS t1_col1,
       t1.col2  AS t1_col2,
       t2.col1  AS t2_col2,
       t2.col1  AS t2_col2
  FROM dbo.my_nullTable1 AS t1
  JOIN dbo.my_nullTable2 AS t2
    ON t1.col1 <> ISNULL(t2.col1, -1)
 ORDER BY t1.col1 ASC;