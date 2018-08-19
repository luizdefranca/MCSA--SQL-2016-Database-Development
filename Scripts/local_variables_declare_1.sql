--
-- https://docs.microsoft.com/en-us/sql/t-sql/language-elements/declare-local-variable-transact-sql?view=sql-server-2017
--
-- DECLARE @local_variable
-- 
-- Variables are declared in the body of a batch or procedure with the DECLARE statement.
--
-- Cursor variables can be declared with this statement and used with other cursor related statements.
--
-- After declaration, all variables are initialized as NULL, unless a value is provided as part of the declaration.
--
-- Syntax:
--
-- DECLARE   
--   {   
--       { @local_variable [AS] data_type  [ = value ] }  
--     | { @cursor_variable_name CURSOR }  
--   } [,...n]   
--   | { @table_variable_name [AS] <table_type_definition> }   
--   
--   <table_type_definition> ::=   
--        TABLE ( { <column_definition> | <table_constraint> } [ ,...n] )   
--   
--   <column_definition> ::=   
--        column_name { scalar_data_type | AS computed_column_expression }  
--        [ COLLATE collation_name ]   
--        [ [ DEFAULT constant_expression ] | IDENTITY [ (seed ,increment ) ] ]   
--        [ ROWGUIDCOL ]   
--        [ <column_constraint> ]   
--   
--   <column_constraint> ::=   
--        { [ NULL | NOT NULL ]   
--        | [ PRIMARY KEY | UNIQUE ]   
--        | CHECK ( logical_expression )   
--        | WITH ( <index_option > )  
--        }   
--   
--   <table_constraint> ::=   
--        { { PRIMARY KEY | UNIQUE } ( column_name [ ,...n] )   
--        | CHECK ( search_condition )   
--        }   
--   
--   <index_option> ::=  
--   See CREATE TABLE for index option syntax.
--

-- Declare a variable initialized to NULL then set it's value
DECLARE @colour VARCHAR(50);
SET @colour = 'RED';
SELECT COUNT(*) AS 'No. of Red Products'
  FROM dbo.MySimpleProducts
 WHERE p_colour = @colour;
GO

-- Declaring multiple variables initialized to NULL then setting their values
DECLARE @red VARCHAR(50), @blue VARCHAR(50);
SET @red = 'RED';
SET @blue = 'BLUE';
SELECT p_colour AS 'Color', COUNT(*) AS 'No. of Products'
  FROM dbo.MySimpleProducts
 WHERE p_colour IN (@red, @blue)
 GROUP BY p_colour;
GO

-- Declare and initialization done in the DECLARE statment (example as above)
DECLARE @red VARCHAR(50) = 'RED', 
        @blue VARCHAR(50) = 'BLUE';
SELECT p_colour AS 'Color', COUNT(*) AS 'No. of Products'
  FROM dbo.MySimpleProducts
 WHERE p_colour IN (@red, @blue)
 GROUP BY p_colour;
GO

--Declare a variable of type table
BEGIN TRANSACTION; 
DECLARE @productTable TABLE(
  name     VARCHAR(50),
  oldCost  NUMERIC(7, 2),
  newCost  NUMERIC(7, 2)
);

WITH cheapestProducts AS (
      SELECT *
	    FROM dbo.MySimpleProducts
	   ORDER BY p_cost ASC
	   OFFSET 0 ROWS FETCH FIRST 5 ROWS ONLY
    )
UPDATE cheapestProducts
   SET p_cost *= 2.1
 OUTPUT DELETED.p_colour,
        DELETED.p_cost,
		INSERTED.p_cost
   INTO @productTable;

SELECT name AS 'Product', oldCost AS 'Old Cost', newCost AS 'New Cost'
  FROM @productTable;

 ROLLBACK TRANSACTION;
 GO


SELECT * FROM dbo.MySimpleProducts;