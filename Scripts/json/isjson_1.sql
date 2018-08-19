--
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/json-functions-transact-sql?view=sql-server-2017
--

--
-- ISJSON returns 1 if the string contains valid JSON; otherwise returns 0.  
-- It returns null if expression is null.
--
-- Syntax: ISJSON(<expression>)
--
SELECT ISJSON('{"say":"hello"}') AS is_json_string,
       ISJSON('say hello') AS is_not_json_string,
	   ISJSON(null) AS is_null;

