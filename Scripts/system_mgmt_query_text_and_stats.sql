--
-- The dm_exec_query_stats has 76 columns so this is only a small fraction of the
-- information available.  I'm really using this to get the query text by calling
-- function dm_exec_query_stats then getting the text but I put some other fields
-- in to see if the information is useful. 
--
SELECT creation_time, last_execution_time, text, last_rows, total_rows, plan_handle
  FROM sys.dm_exec_query_stats AS qs
  CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
 WHERE last_execution_time > DATEFROMPARTS(2018, 08, 18)
   AND text LIKE '%departments%'
 ORDER BY last_execution_time DESC;

 GO

--
-- If you want to see the query plan for one of the above copy the plan_handle and
-- paste as the value of variable @my_plan_value.  The table function dm_exec_query_plan
-- accepts the plan_handle as an argument (remember it's a VARBINARY so don't use single
-- quotes) and returns a row with the query_plan as XML.
--
-- What's cool is that you click on the field value it'll open up the visual plan and 
-- include the information when you hover over an operation.
--
DECLARE @my_plan_handle VARBINARY(64);
SET @my_plan_handle = 0x06000500EA7D0D14C0D9E2525602000001000000000000000000000000000000000000000000000000000000

SELECT *
  FROM sys.dm_exec_query_plan(@my_plan_handle);

GO
