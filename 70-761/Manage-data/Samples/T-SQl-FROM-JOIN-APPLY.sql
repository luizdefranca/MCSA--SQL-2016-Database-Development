--
-- https://docs.microsoft.com/en-us/sql/t-sql/queries/from-transact-sql?view=sql-server-2017#using-apply
--
-- APPLY
-- 
-- (APPLY isn't standard; the standard SQL counterpart is LATERAL)
--
-- Syntax: left_table_source { CROSS | OUTER } APPLY right_table_source   
--
-- Both the left and right operands of the APPLY operator are table expressions. The main 
-- difference between these operands is that the right_table_source can use a table-valued 
-- function that takes a column from the left_table_source as one of the arguments of the 
-- function. The left_table_source can include table-valued functions, but it cannot contain 
-- arguments that are columns from the right_table_source. 
-- 
-- It works in the following way to produce table source for the FROM clause:
--
-- 1.  Evaluates right_table_source against each row of the left_table_source to produce rowsets. 
--     The values in the right_table_source depend on left_table_source. right_table_source can be 
--     represented approximately this way: TVF(left_table_source.row), where TVF is a table-valued 
--     function. 
--
-- 2.  Combines the result sets that are produced for each row in the evaluation of right_table_source 
--     with the left_table_source by performing a UNION ALL operation.  
--     The list of columns produced by the result of the APPLY operator is the set of columns from 
--     the left_table_source that is combined with the list of columns from the right_table_source. 
--
-- (prerequisite - T-SQL-MY-GENERIC-SAMPLE-TABLE.sql)
-- 

-- -------------------------------------------------------------------------------------------------------
--
-- CROSS APPLY with the same result as CROSS JOIN 
--
-- The following queries produce the same results.
-- 1.  The first query returns the cross product of MyLeftTable and MyRightTable.
-- 2.  The second query evaluates MyRightTable for each row of MyLeftTable.
--
-- Conclusion: CROSS APPLY where the right_table_source does not depend on the left_table_source
--             is similar to a CROSS JOIN.
--
SELECT l_id, r_id
  FROM dbo.MyLeftTable
  CROSS JOIN dbo.MyRightTable;
  
SELECT l_id, r_id
  FROM dbo.MyLeftTable
  CROSS APPLY dbo.MyRightTable;
  
-- -------------------------------------------------------------------------------------------------------
--  
-- CROSS APPLY where right_table_source depends on left_table_source
--
-- right_table_source is a derived table / table expression.
--
-- The following queries produce the same results:
-- 1.  The first query uses an INNER JOIN on MyLeftTable and MyRightTable returning only matching rows.
-- 2.  The second query evaluates the derived table for each row of MyLeftTable and returns matching rows.
--
-- Conclusion: CROSS APPLY where the right_table_source depends on left_table_source is similar to an
--             INNER JOIN.
--
SELECT l_id, r_id
  FROM dbo.MyLeftTable
  JOIN dbo.MyRightTable
    ON l_id = r_l_id;
     
SELECT l_id, r_id
  FROM dbo.MyLeftTable AS lt
  CROSS APPLY (
    SELECT r_id
      FROM dbo.MyRightTable AS rte
     WHERE rte.r_l_id = lt.l_id
  ) AS rt;

-- -------------------------------------------------------------------------------------------------------
--  
-- OUTER APPLY where right_table_source depends on left_table_source
--
-- right_table_source is a derived table / table expression.
--
-- The following queries produce the same results:
-- 1.  The first query uses a LEFT OUTER JOIN on MyLeftTable and MyRightTable returning matching rows plus
--     non-matching rows in the preserved left table.
-- 2.  The second query evaluates the derived table for each row of MyLeftTable and returns matching rows
--     plus non-matching rows in the preseved left table.
--
-- Conclusion: OUTER APPLY is similar to a LEFT OUTER JOIN.  
--             There isn't an APPLY similar to RIGHT OUTER JOIN because the right_table_source is evaluated
--             for each row of the left_table_source.
--  
SELECT l_id, r_id
  FROM dbo.MyLeftTable
  LEFT JOIN dbo.MyRightTable
    ON l_id = r_l_id;
    
SELECT l_id, r_id
  FROM dbo.MyLeftTable AS lt
  OUTER APPLY (
    SELECT r_id
      FROM dbo.MyRightTable AS rte
     WHERE rte.r_l_id = lt.l_id 
  ) AS rt;
  
