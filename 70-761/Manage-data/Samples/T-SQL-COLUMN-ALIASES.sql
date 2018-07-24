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
