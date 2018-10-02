--
-- Test table
--
DROP TABLE IF EXISTS dbo.test_data;

SELECT CAST(n AS INT) AS col1, ((ABS(CHECKSUM(NEWID()))) % 199) * 100 AS col2
  INTO dbo.test_data
  FROM dbo.getNums(1, 100000);

ALTER TABLE dbo.test_data
  ALTER COLUMN col1 INT NOT NULL;

GO

ALTER TABLE dbo.test_data
  ADD CONSTRAINT test_data_pk PRIMARY KEY (col1);

GO

--
-- APPROX_COUNT_DISTINCT
--
SELECT APPROX_COUNT_DISTINCT(col2) AS apprx_count_distinct
  FROM dbo.test_data;

SELECT COUNT(DISTINCT col2) AS count_distinct
  FROM dbo.test_data;

--
-- AVG aggregate
-- 
SELECT AVG(col2) AS average_all,  AVG(DISTINCT col2) AS average_distinct
  FROM dbo.test_data;

SELECT AVG(val) AS average_all, AVG(DISTINCT val) AS average_distinct
  FROM (VALUES(100),(100),(200)) AS v(val);

--
-- AVG analytic
--
SELECT col1, col2, 
       AVG(col2) OVER() AS average_all,
       AVG(col2) OVER(ORDER BY col1) average_roll,
       group_no,
       AVG(col2) OVER(PARTITION BY group_no) average_part,
       AVG(col2) OVER(PARTITION BY group_no ORDER BY col1) average_part_roll
  FROM dbo.test_data
  CROSS APPLY (
    SELECT CAST(col1 AS INT) / 100
  ) AS groups(group_no)
 WHERE col1 <= 1000;

--
-- Why the GROUP_NO calculation (above) works.  The result of the first
-- expression is an INT (1) and the result of the second expression is
-- MONEY (1.51) see 
-- https://docs.microsoft.com/en-us/sql/t-sql/language-elements/divide-transact-sql?view=sql-server-2017
--
SELECT CAST(151 AS INT) / 100 AS int_divided_by_100,
       CAST(151 AS MONEY) / 100 AS money_divided_by_100;

SELECT NTILE(1000) OVER(ORDER BY col1) 
  FROM dbo.test_data;

--
-- CHECKSUM_AGG
--
-- Local temporary table
DROP TABLE IF EXISTS #local_test_data;
GO
SELECT CAST(n AS INT) AS col1, ((ABS(CHECKSUM(NEWID()))) % 199) * 100 AS col2
  INTO #local_test_data
  FROM dbo.getNums(1, 1000);
GO
CREATE OR ALTER PROCEDURE checkSumAgg_Test
AS
SELECT CHECKSUM_AGG(col1), CHECKSUM_AGG(col2)
  FROM #local_test_data;
GO

INSERT INTO #local_test_data(col1, col2)
     VALUES(1001,92232);

EXEC checkSumAgg_Test;

DELETE FROM #local_test_data
      WHERE col1 = 1001;

EXEC checkSumAgg_Test;

