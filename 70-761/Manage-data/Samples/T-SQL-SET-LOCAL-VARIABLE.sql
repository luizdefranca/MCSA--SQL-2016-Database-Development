--
-- https://docs.microsoft.com/en-us/sql/t-sql/language-elements/set-local-variable-transact-sql?view=sql-server-2017
--
-- SET @local_variable
--
-- Sets the local variable, previously created using the DECLARE @local_variable statement, to
-- the specified value
-- 
-- Syntax:
--
-- SET   
--   { @local_variable  
--       [ . { property_name | field_name } ] = { expression | udt_name { . | :: } method_name }  
--   }  
--   |  
--   { @SQLCLR_local_variable.mutator_method  
--   }  
--   |  
--   { @local_variable  
--       {+= | -= | *= | /= | %= | &= | ^= | |= } expression  
--   }  
--   |   
--     { @cursor_variable =   
--       { @cursor_variable | cursor_name   
--       | { CURSOR [ FORWARD_ONLY | SCROLL ]   
--           [ STATIC | KEYSET | DYNAMIC | FAST_FORWARD ]   
--           [ READ_ONLY | SCROLL_LOCKS | OPTIMISTIC ]   
--           [ TYPE_WARNING ]   
--       FOR select_statement   
--           [ FOR { READ ONLY | UPDATE [ OF column_name [ ,...n ] ] } ]   
--         }   
--       }  
--   } 
--

-- Simple SET and printing the value of the variable 
DECLARE @colour VARCHAR(50);
SET @colour = 'BLUE';
SELECT @colour AS 'Colour 1';
GO

-- Assigning a value to a local variable then using it in a SELECT statement
DECLARE @id INT;
SET @id = 1;
SELECT p_colour  
  FROM dbo.MySimpleProducts
 WHERE p_id = @id;
GO

-- Using a compound assignment for a local variable
DECLARE @val  INT;
SET @val = 10;
SET @val = @val + 20;
SELECT @val AS 'Value 1';
GO

DECLARE @val  INT;
SET @val = 10;
SET @val += 20;
SELECT @val AS 'Value 2';
GO

--Using SET with a GLOBAL CURSOR
DECLARE my_cursor CURSOR GLOBAL   
FOR SELECT p_colour AS 'GC Colour' FROM dbo.MySimpleProducts;  
DECLARE @my_variable CURSOR ;  
SET @my_variable = my_cursor ;   
--There is a GLOBAL cursor declared(my_cursor) and a LOCAL variable  
--(@my_variable) set to the my_cursor cursor.  
DEALLOCATE my_cursor;   
--There is now only a LOCAL variable reference  
--(@my_variable) to the my_cursor cursor.
OPEN @my_variable;
FETCH NEXT FROM @my_variable;
WHILE @@FETCH_STATUS = 0
BEGIN
  FETCH NEXT FROM @my_variable;
END;
CLOSE @my_variable;
DEALLOCATE @my_variable;
GO

--Defining a cursor by using SET
DECLARE @cursorVar CURSOR;
DECLARE @colour VARCHAR(50);
DECLARE @count  INT;
SET @cursorVar = CURSOR SCROLL DYNAMIC
FOR SELECT p_colour AS 'C Colour', COUNT(*) AS '# of Products'
      FROM dbo.MySimpleProducts GROUP BY p_colour;

OPEN @cursorVar;
FETCH NEXT FROM @cursorVar INTO @colour, @count;
WHILE @@FETCH_STATUS = 0
BEGIN
  SELECT @colour AS 'CF Colour', @count AS 'CF Count';
  FETCH NEXT FROM @cursorVar INTO @colour, @count;	
END;

CLOSE @cursorVar;
DEALLOCATE @cursorVar;
GO

--Repeats the above example but also uses a table variable
DECLARE @cursorVar CURSOR,
        @colour VARCHAR(50),
        @count  INT;

DECLARE @colourTable TABLE(
  colour  VARCHAR(50),
  count   INT
);

SET @cursorVar = CURSOR SCROLL DYNAMIC
FOR SELECT p_colour AS 'C Colour', COUNT(*) AS '# of Products'
      FROM dbo.MySimpleProducts GROUP BY p_colour;
      
OPEN @cursorVar;
FETCH NEXT FROM @cursorVar INTO @colour, @count;
WHILE @@FETCH_STATUS = 0
BEGIN
  INSERT INTO @colourTable(colour, count) VALUES (@colour, @count);
  FETCH NEXT FROM @cursorVar INTO @colour, @count;	
END;

SELECT colour AS 'TV Colour', count AS 'TV Count'
  FROM @colourTable;

CLOSE @cursorVar;
DEALLOCATE @cursorVar;
GO  

--Assigning a value from a scalar query
DECLARE @count INT;
SET @count = (SELECT COUNT(*) FROM dbo.MySimpleProducts);
SELECT @count AS 'Row Count';
GO
