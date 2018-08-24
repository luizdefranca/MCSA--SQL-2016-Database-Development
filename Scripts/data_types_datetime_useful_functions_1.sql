--
-- Calculating the end of year
-- 
-- Taken from https://mva.microsoft.com/en-US/training-courses/boost-your-tsql-with-the-apply-operator-8270?l=hVhkL4Vy_4504984382
-- (Improving Scalar User Defined Functions).
--
DROP FUNCTION IF EXISTS dbo.EndOfYear;
GO

CREATE FUNCTION dbo.EndOfYear(
  @dt  AS  DATETIME
) 
RETURNS DATETIME
AS
BEGIN

  RETURN DATEADD(YEAR, DATEDIFF(YEAR, '18991231', @dt), '18991231');

END;
GO

EXEC sys.sp_addextendedproperty 
  @name = N'Caption', 
  @value = N'Returns the end of year (DATETIME) for the input date (DATETIME)', 
  @level0type = N'SCHEMA', @level0name = [dbo],
  @level1type = N'FUNCTION', @level1name = EndOfYear;
GO

SELECT dbo.EndOfYear(sysdatetime()) AS end_of_this_year;