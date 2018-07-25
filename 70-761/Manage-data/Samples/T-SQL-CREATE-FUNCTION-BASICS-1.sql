--
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/create-function-transact-sql?view=sql-server-2017
-- https://docs.microsoft.com/en-us/sql/t-sql/language-elements/select-local-variable-transact-sql?view=sql-server-2017
--

--
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
SELECT dbo.getSimpleProductColour(1);
