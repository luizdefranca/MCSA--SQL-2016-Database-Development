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

-- Using SELECT @local_variable to return a single value.
-- Declare the variable and assign it a default of NONE
DECLARE @colour VARCHAR(50);
SELECT @colour = 'NONE';

-- This SELECT statement returns no rows...
SELECT @colour = p_colour
  FROM dbo.MySimpleProducts
 WHERE p_id = -1000;

--So the colour variable retains the value NONE
SELECT @colour AS 'Colour 1';

-- This SELECT statement returns 1 row...
SELECT @colour = p_colour
  FROM dbo.MySimpleProducts
 WHERE p_id = 1;

--So the colour variable is set to the value RED
SELECT @colour AS 'Colour 2';

--This SELECT statement is a scalar subquery and returns no rows
--Note the difference to the preceding examples...
SELECT @colour = (SELECT p_colour 
                    FROM dbo.MySimpleProducts
                   WHERE p_id = -1000);

--So the colour variable is set to NULL
SELECT @colour AS 'Colour 3';  

--This SELECT returns more than 1 row...
SELECT @colour = p_colour
  FROM dbo.MySimpleProducts
 WHERE p_colour IS NOT NULL
 ORDER BY p_colour ASC;

--So the colour variable is set to the last value returned by the query
SELECT @colour AS 'Colour 4'; 

GO

-- Using SELECT @local_variable to return a multiple values
-- Declare the variables and assign them defaults
DECLARE @colour VARCHAR(50), 
        @cost   NUMERIC(7,2);
SET @colour = 'NONE';
SET @cost = 1.99;

-- This SELECT statement returns 1 row...
SELECT @colour = p_colour,
       @cost = p_cost
  FROM dbo.MySimpleProducts
 WHERE p_id = 1;

 --So the colour variable is set to RED and cost to 123.00
SELECT @colour AS 'Colour', 
       @cost AS 'Cost';
    
GO