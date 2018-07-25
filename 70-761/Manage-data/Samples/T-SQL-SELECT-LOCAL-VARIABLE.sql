--
-- https://docs.microsoft.com/en-us/sql/t-sql/language-elements/select-local-variable-transact-sql?view=sql-server-2017
--
-- SELECT @local_variable
--
-- Syntax:
--
-- SELECT { @local_variable { = | += | -= | *= | /= | %= | &= | ^= | |= } expression } 
--   [ ,...n ] [ ; ]  
--
--
-- Sets a local variable to the value of an expresion.
--
-- For assigning variables the documentation recommends using SET @local_variable instead of 
-- SELECT @local_variable
--
-- SELECT @local_variable is typically used to return a single value into the variable.
-- However, when expression is the name of a column, it can return multiple values. 
-- If the SELECT statement returns more than one value, the variable is assigned the 
-- last value that is returned.
--
-- If the SELECT statement returns no rows, the variable retains its present value. 
-- If expression is a scalar subquery that returns no value, the variable is set to NULL.
--
-- One SELECT statement can initialize multiple local variables.
--

-- Using SELECT @local_variable to return a single value
DECLARE @colour VARCHAR(50);
SELECT @colour = 'NONE';

-- This SELECT statement returns no rows
SELECT @colour = p_colour
  FROM dbo.MySimpleProducts
 WHERE p_id = -1000;

--So the colour variable retains the value NONE
SELECT @colour AS 'Colour 1';

-- This SELECT statement returns 1 row
SELECT @colour = p_colour
  FROM dbo.MySimpleProducts
 WHERE p_id = 1;

--So the colour variable is set to the value RED
SELECT @colour AS 'Colour 2';