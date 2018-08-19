--
-- https://docs.microsoft.com/en-us/sql/t-sql/queries/select-order-by-clause-transact-sql?view=sql-server-2017
--
-- <OFFSET_FETCH> is part part of the ORDER BY clause in T-SQL.  Therefore if you omit the ORDER BY clause you get:
--   Failed to execute query. Error: Incorrect syntax near '5'.  
--   Invalid usage of the option NEXT in the FETCH statement.
--
-- It's the equivalent of the <ROW-LIMITING-CLAUSE> of the SELECT statement in Oracle SQL (12c), except (not exhaustive)
-- 1.  You don't require an ORDER BY clause in Oracle SQL
-- 2.  In Oracle SQL both OFFSET and FETCH clauses are optional whereas in T-SQL only FETCH is optional
-- 3.  You cannot use WITH TIES or PERCENT in T-SQL (although T-SQL does have a TOP query operator)
--
-- Highlight and run the following examples in the Azure Query editor

-- You can omit the FETCH clause
SELECT productid, name, productnumber, color
  FROM SalesLT.Product
 ORDER BY productid
 OFFSET 5 ROWS;

-- You can interchange ROW and ROWS, FETCH FIRST and FETCH NEXT for semantic clarity
SELECT productid, name, productnumber, color
  FROM SalesLT.Product
 ORDER BY productid
 OFFSET 5 ROWS FETCH NEXT 1 ROW ONLY;

SELECT productid, name, productnumber, color
  FROM SalesLT.Product
 ORDER BY productid
 OFFSET 1 ROW FETCH NEXT 1 ROW ONLY;
 
SELECT productid, name, productnumber, color
  FROM SalesLT.Product
 ORDER BY productId
 OFFSET 0 ROWS FETCH FIRST 2 ROWS ONLY;

--You can use variables in the OFFSET and FETCH clauses
DECLARE
  @startingRowNumber tinyint=1, 
  @fetchRows tinyint=8;
SELECT productid, name, productnumber, color
  FROM SalesLT.Product
 ORDER BY productId
 OFFSET @startingRowNumber ROWS FETCH FIRST @fetchRows ROWS ONLY; 

--You can use expressions in the OFFSET and FETCH clauses
DECLARE
  @startingRowNumber tinyint=1, 
  @fetchRows tinyint=8;
SELECT productid, name, productnumber, color
  FROM SalesLT.Product
 ORDER BY productId
 OFFSET @startingRowNumber + 1 ROWS FETCH FIRST @fetchRows - 4 ROWS ONLY; 

 --You can specify a constant scalar subquery in the OFFSET and FETCH clauses
DROP TABLE IF EXISTS dbo.MyInts;

CREATE TABLE dbo.MyInts(
  intKey   VARCHAR(25) NOT NULL,
  intValue INT         NOT NULL
);

INSERT INTO dbo.MyInts(intKey, intValue) VALUES ('startingRowNumber', 1);
INSERT INTO dbo.MyInts(intKey, intValue) VALUES ('fetchRows', 8);

SELECT productid, name, productnumber, color
  FROM SalesLT.Product
 ORDER BY productId
 OFFSET (SELECT intValue FROM dbo.MyInts WHERE intKey = 'startingRowNumber') ROWS 
 FETCH FIRST (SELECT intValue FROM dbo.MyInts WHERE intKey = 'fetchRows') ROWS ONLY; 
