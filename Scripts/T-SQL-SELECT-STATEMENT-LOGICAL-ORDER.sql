--
-- https://docs.microsoft.com/en-us/sql/t-sql/queries/select-transact-sql?view=sql-server-2017
--
-- Logical processing order is:
--  1.  FROM
--  2.  ON
--  3.  JOIN
--  4.  WHERE
--  5.  GROUP BY
--  6.  WITH CUBE or WITH ROLLUP
--  7.  HAVING
--  8.  SELECT
--  9.  DISTINCT
--  10. ORDER BY
--  11. TOP
--
-- Note that because the SELECT clause is step 8, any column aliases or derived columns 
-- defined in that clause cannot be referenced by any preceding clauses
--

--
-- Some examples:
--
-- FROM (1), SELECT (8) and ORDER BY (10).  The ORDER BY can refer to the column alias.
SELECT SalesOrderId, ProductId, LineTotal, OrderQty * UnitPrice AS CalcdLineTotal 
  FROM SalesLT.SalesOrderDetail
 ORDER BY CalcdLineTotal;

--FROM (1), GROUP BY (5), SELECT (8) and ORDER BY (10).  The ORDER BY can refer to the
--column alias but the GROUP BY cannot.
SELECT SalesOrderId AS OrderId, SUM(LineTotal) AS OrderTotal
  FROM SalesLT.SalesOrderDetail
 GROUP BY SalesOrderId  --OrderId results in "Invalid column name 'OrderId'."
 ORDER BY OrderId;

--Getting around the above using a TABLE expression, so the order is now...
--table expression: FROM (1) and SELECT (8), 
--main query FROM <table expression> (1), GROUP BY (5), SELECT (8) and ORDER BY (10)
--
--The query selects FROM a table (albeit an expression) with columns named OrderId and OrderLineTotal
SELECT OrderId, SUM(OrderLineTotal) AS OrderTotal
  FROM (
    SELECT SalesOrderId AS OrderId, LineTotal AS OrderLineTotal
	  FROM SalesLT.SalesOrderDetail
  ) AS OrderDetails
 GROUP BY OrderId  --SalesOrderId would now results in "Invalid column name 'SalesOrderId'."
 ORDER BY OrderId;
 
--As above but using a CTE (common table expression)...
WITH OrderDetails AS (
  SELECT SalesOrderId AS OrderId, LineTotal AS OrderLineTotal
	FROM SalesLT.SalesOrderDetail 
)
SELECT OrderId, SUM(OrderLineTotal) AS OrderTotal
  FROM OrderDetails
 GROUP BY OrderId
 ORDER BY OrderId;

--(aside) This example uses the Table Value Constructor and assigns an alias of num to the table
--and aliases num1 and num2 to the columns.
--https://docs.microsoft.com/en-us/sql/t-sql/queries/table-value-constructor-transact-sql?view=sql-server-2017
--
--FROM (1), SELECT (8), DISTINCT (9) and ORDER BY (10).  The DISTINCT applies to the result of the
--expression num1 + num2
SELECT DISTINCT num1 + num2 AS num1PlusNum2
  FROM (VALUES
    (1, 2), (1, 3), (1, 3), (2, 1), (3, 4)
  ) AS nums(num1, num2)
 ORDER BY num1PlusNum2 DESC;

--FROM (1), GROUP BY (5), HAVING (7), SELECT (8) and ORDER BY (10).  In this case num1 + num2 is
--assigned the alias num1PlusNum2.  You ccan refer to the expression in the GROUP BY and the alias
--in the ORDER BY
SELECT num1 + num2 AS num1PlusNum2, SUM(num1) AS sumNum1s, SUM(num2) AS sumNum2s
  FROM (VALUES
    (1, 2), (1, 3), (1, 3), (2, 1), (3, 4)
  ) AS nums(num1, num2)
 GROUP BY num1 + num2
 HAVING SUM(num1) > 3
 ORDER BY num1PlusNum2;
