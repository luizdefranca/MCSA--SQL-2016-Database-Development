--
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/create-function-transact-sql?view=sql-server-2017
--
-- Also read your notes on variables:
--   T-SQL-DECLARE-LOCAL-VARIABLE.sql
--   T-SQL-SELECT-LOCAL-VARIABLE.sql
--   T-SQL-SET-LOCAL-VARIABLE.sql
--
-- This just goes over some of the basics for creating functions.  There's obviously lots to get your
-- head around, not just the create function syntax but all the language elements you can use in the
-- function.
--
--
-- Note that there has to be a GO inbetween the DROP and CREATE FUNCTION statements otherwise:
--   "Failed to execute query. Error: 'CREATE FUNCTION' must be the first statement in a query batch."
--

--Simple "scalar function" that returns the product colour for an input id
DROP FUNCTION IF EXISTS dbo.getSimpleProductColour;
GO
CREATE FUNCTION dbo.getSimpleProductColour(
  @p_id  INT
)
RETURNS VARCHAR(50)
AS
BEGIN
  DECLARE @colour  VARCHAR(50);

  SELECT @colour = p_colour
    FROM dbo.mySimpleProducts
   WHERE p_id = @p_id;

  RETURN(@colour);
END;
GO
SELECT dbo.getSimpleProductColour(1) AS 'Colour V1';

--As above but an alternative way of setting the @colour variable, building on it a bit.  There are
--obviously some parts to the function that would be better in the query but I'm just learning the
--syntax at the moment.
DROP FUNCTION IF EXISTS dbo.getSimpleProductColour;
GO
CREATE FUNCTION dbo.getSimpleProductColour(
  @p_id    INT,
  @p_case  VARCHAR(20) = 'UPPER'
)
RETURNS VARCHAR(50)
AS
BEGIN
  DECLARE @colour    VARCHAR(50);  

  SET @colour = (
   SELECT p_colour
     FROM dbo.mySimpleProducts
    WHERE p_id = @p_id
  );

  SET @colour = CASE @p_case
                  WHEN 'UPPER' THEN  
                    UPPER(@colour)
                  WHEN 'LOWER' THEN  
                    LOWER(@colour)
                  ELSE --There isn't an INITCAP function
                    @colour
                  END;
                  
  --Not good by any means, just using a few more language elements 
  --(the lack of THEN and END IF will take a bit of getting used to and stop forgetting
  -- to use SET when setting variables!!!!)
  IF @p_case = 'INITCAP'
    BEGIN
      SET @colour = CONCAT(
                      UPPER(SUBSTRING(@colour, 1, 1)),
                      LOWER(SUBSTRING(@colour, 2, LEN(@colour) -1))
                    );
    END;
    
  RETURN(@colour);
END;
GO
SELECT dbo.getSimpleProductColour(1, DEFAULT) AS 'Colour V2';
