--
-- https://docs.microsoft.com/en-us/sql/t-sql/language-elements/set-operators-union-transact-sql?view=sql-server-2017
-- (Kindle) T-SQL Fundamentals page 193 (location 6138)
--
-- Combines the results of two or more queries into a single result set that includes all the rows
-- that belong to the queries in the union.  Basic rules:
-- 1.  The number and order of the columns must be the same in all queries
-- 2.  The data types must be compatible
--
-- UNION specifies that multiple result sets are to be combined as a single result set.
-- ALL incorporates all rows into the results including duplicates.
--

--
-- Simple UNION.  Notes:
-- 1. The UNION removes the duplicates from the combined result set
-- 2. The UNION effectively treats NULLs
SELECT p_colour
  FROM dbo.MySimpleProducts
 UNION
SELECT p_colour 
  FROM dbo.MySimpleProducts;