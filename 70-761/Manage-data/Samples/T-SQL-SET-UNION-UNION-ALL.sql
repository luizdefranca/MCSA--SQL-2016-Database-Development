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
-- Simple UNION.
--
-- 1. The UNION removes the duplicates from the combined result set.  
-- 2. The UNION treats NULL as if it were a non-NULL value (i.e. the removal of
--    duplicates also removes duplicate NULLs)
SELECT p_colour
  FROM dbo.MySimpleProducts
 UNION
SELECT p_colour 
  FROM dbo.MySimpleProducts;
  
-- 3. Note that in removing duplicates from the combined result set it's effectively
--    removing duplicates from any given result set in the UNION.  This can mask
--    potential issues with joins (e.g. the accidental cross join below)
SELECT a.p_colour
  FROM dbo.MySimpleProducts a,
       dbo.MySimpleProducts b
 UNION
SELECT 'YELLOW';

-- Simple UNION ALL.
--
-- Simply returns the combined result set
SELECT p_colour
  FROM dbo.MySimpleProducts
 UNION ALL
SELECT p_colour 
  FROM dbo.MySimpleProducts;
  
-- Combining more than two result sets.
--
-- The following examples show how the order of the UNION and UNION ALL operations
-- affect the result set returned by the query.
--
-- 1.  A and B are combined.  The result of A and B is combined with C removing duplicates.
--     There are no duplicates in the result set returned by the query.
SELECT p_colour
  FROM dbo.MySimpleProducts a
 UNION ALL
SELECT p_colour 
  FROM dbo.MySimpleProducts b
 UNION
SELECT p_colour
  FROM dbo.MySimpleProducts c;
  
--2.  A and B are combined removing duplicates.  The result of A and B is combined with C.
--    There are duplicates in the result set returned by the query.
SELECT p_colour
  FROM dbo.MySimpleProducts a
 UNION
SELECT p_colour 
  FROM dbo.MySimpleProducts b
 UNION ALL
SELECT p_colour
  FROM dbo.MySimpleProducts c;  
  
--3.  As (2) but parenthesis change the ordering of the UNION operations to return the 
--    same result as (1).
SELECT p_colour
  FROM dbo.MySimpleProducts a
 UNION
( 
SELECT p_colour 
  FROM dbo.MySimpleProducts b
 UNION ALL
SELECT p_colour
  FROM dbo.MySimpleProducts c
);

-- Using an ORDER BY
--
-- A set operator expects multisets as inputs and for multisets order does not matter
-- in discriminating multisets ({1,2,3} and {3,1,2} denote the same multiset).  The
-- T-SQL Fundamentals book goes a step further to say that the result of a query with 
-- an ORDER BY isn't a multiset it's a cursor.  Anyway....
--
-- You can't do this
SELECT p_colour
  FROM dbo.MySimpleProducts a
 ORDER BY p_colour
 UNION
SELECT 'YELLOW';
