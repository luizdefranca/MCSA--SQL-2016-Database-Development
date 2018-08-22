--
-- Integers (int, bigint, smallint, and tinyint)
--
-- https://docs.microsoft.com/en-us/sql/t-sql/data-types/data-types-transact-sql?view=sql-server-2017
-- https://docs.microsoft.com/en-us/sql/t-sql/data-types/int-bigint-smallint-and-tinyint-transact-sql?view=sql-server-2017
--
-- Exact number data types that use integer data.  To save space use the smallest data type that
-- can reliably contain all possible values.  For example TINYINT would be suitable for a person's
-- age but not for the number of days in a year.
--
-- This example creates a table using the integer data types and populates it will the lowest and
-- highest values of the permitted ranges.  It queries the data and uses sp_help to describe the table.
-- The last part of the example shows an overflow error.
DROP TABLE IF EXISTS dbo.my_int_values;

CREATE TABLE dbo.my_int_values(
  my_comment     VARCHAR(100), 
  my_bigint      BIGINT,        /* Storage 8 bytes */
  my_int         INT,           /* Storage 4 bytes */
  my_smallint    SMALLINT,      /* Storage 2 bytes */
  my_tinyint     TINYINT        /* Storage 1 byte  */
);

GO

BEGIN TRANSACTION

INSERT INTO dbo.my_int_values(
  my_comment,    
  my_bigint,     
  my_int,    
  my_smallint,
  my_tinyint
) VALUES (
  'Range - low value',
  CAST(POWER(-2.0, 63.0 ) AS BIGINT),
  CAST(POWER(-2.0, 31.0 ) AS INT),
  CAST(POWER(-2.0, 15.0 ) AS SMALLINT),
  CAST(0 AS TINYINT)
), (
  'Range - high value',
  CAST(POWER(2.0, 63.0 ) -1.0 AS BIGINT),
  CAST(POWER(2.0, 31.0 ) -1.0 AS INT),
  CAST(POWER(2.0, 15.0 ) -1.0 AS SMALLINT),
  CAST(255 AS TINYINT)
);

COMMIT TRANSACTION

SELECT * FROM dbo.my_int_values;

GO

sp_help [dbo.my_int_values]

GO

--
-- Arithmetic overflow example
--
DECLARE @myTinyInt  TINYINT;
BEGIN TRY
  SET @myTinyInt = 256;
END TRY
BEGIN CATCH
  SELECT ERROR_NUMBER()    AS ErrorNumber,  
         ERROR_SEVERITY()  AS ErrorSeverity,  
         ERROR_STATE()     AS ErrorState, 
         ERROR_PROCEDURE() AS ErrorProcedure,  
         ERROR_LINE()      AS ErrorLine,  
         ERROR_MESSAGE()   AS ErrorMessage; 
END CATCH;
GO
