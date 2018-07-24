--
-- https://docs.microsoft.com/en-us/sql/t-sql/queries/select-clause-transact-sql?view=sql-server-2017
--
-- The following snippet is the bottom part of the <select_list> of the SELECT syntax:
--          [ [ AS ] column_alias ]   
--         }  
--      | column_alias = expression    
--

--
-- [ [ AS ] column_alias ]  
-- You can specify the column alias to the right of the column / expression etc.  The 
-- AS keyword is optional but good practice if you're using this syntax
--
SELECT salesOrderId, 
       orderQty * unitPrice AS totalPrice,
       lineTotal
  FROM SalesLT.SalesOrderDetail;

-- The use of the AS keyword is good practice because it makes the intent to alias clear
-- to someone reviewing the code and reduces the chance of a missing comma going undetected.
-- This query is the same as the above but omits the AS keyword.
SELECT salesOrderId, 
       orderQty * unitPrice totalPrice,
       lineTotal
  FROM SalesLT.SalesOrderDetail;

-- I made a mistake in the query (or did I?).  I put the select list on one line to make it
-- harder for a reviewer to understand what my intention was.
-- 1.  Did I intend assign an the lineTotal alias the expression orderQty * unitPrice?
-- 2.  or did I miss a comma and intended the query to return 3 columns?
SELECT salesOrderId, orderQty * unitPrice lineTotal
  FROM SalesLT.SalesOrderDetail;

-- column_alias = expression
-- You can specify the column alias to the left of the column / expression etc using
-- the equals operator (=).  The internet has lots of opinions on which is better 
-- (expression [AS] column_alias or column_alias = expression).  For example:
-- https://stackoverflow.com/questions/1503295/t-sql-aliasing-using-versus-as
--
-- Both are valid but "expression [AS] column_alias" is valid ANSI SQL whereas
-- "column_alias = expression" is a T-SQL extension.
SELECT salesOrderId, 
       totalPrice = orderQty * unitPrice,
       lineTotal
  FROM SalesLT.SalesOrderDetail;
  
-- Alternative aliasing with table expressions and common table expressions
-- (See Kindle - T-SQL Fundamentals page 164 - location 5322)
-- The table expression below specifies an alias for each of its 3 columns
SELECT *
  FROM (
    SELECT salesOrderId         AS orderId, 
           productId            AS product,
           orderQty * unitPrice AS price
      FROM SalesLT.SalesOrderDetail
 ) AS purchaseOrders;  
 
-- This could also be written using a different form of aliasing where you
-- specify all target column names in parenthesis () following the table
-- expressions name
 SELECT *
  FROM (
    SELECT salesOrderId, 
           productId,
           orderQty * unitPrice
      FROM SalesLT.SalesOrderDetail
 ) AS purchaseOrders(orderId, product, price);  
 
-- Or, as a CTE (common table expression)
WITH purchaseOrders(orderId, product, price) AS (
    SELECT salesOrderId, 
           productId,
           orderQty * unitPrice
      FROM SalesLT.SalesOrderDetail
)
SELECT *
  FROM purchaseOrders;      
