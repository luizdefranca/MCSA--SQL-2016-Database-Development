--
-- https://docs.microsoft.com/en-us/sql/t-sql/queries/from-transact-sql?view=sql-server-2017
-- https://docs.microsoft.com/en-us/sql/t-sql/queries/from-using-pivot-and-unpivot?view=sql-server-2017
--

-- -- -----------------------------------------------------------------------------------------
--
-- Basic PIVOT example.  
--
-- Report on the average cost for each product colour.
--
SELECT p_colour, AVG(p_cost) AS p_average_cost
  FROM dbo.MySimpleProducts
 GROUP BY p_colour;

--
-- Display the same results, pivoted so that the product colour becomes the column headings.
-- Note that even though colour is a VARCHAR column it's value is not in quotes but in square 
-- brackets ([]) even the value (ROSE GOLD) with a space.
--
SELECT *
  FROM (
    SELECT p_colour, p_cost
      FROM dbo.MySimpleProducts
  ) AS SourceTable
  PIVOT (
    AVG(p_cost) 
      FOR p_colour IN ([RED], [BLUE], [GREEN], [ROSE GOLD])
  ) AS PivotTable;  