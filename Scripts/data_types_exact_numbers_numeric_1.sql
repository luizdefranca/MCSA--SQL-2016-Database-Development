--
-- Decimal and Numeric (synonyms for the same data type)
--
-- https://docs.microsoft.com/en-us/sql/t-sql/data-types/data-types-transact-sql?view=sql-server-2017
-- https://docs.microsoft.com/en-us/sql/t-sql/data-types/decimal-and-numeric-transact-sql?view=sql-server-2017
--
-- Numeric data types that have fixed precision and scale.  Decimal and numeric are synonyms and can be used
-- interchangeably.  FYI: these behave in the same way as the Oracle NUMBER data type.
--
-- Syntax: DECIMAL[(p[,s])] or NUMERIC[(p[,s])] 
--
-- p = precision.  The total number of decimal digits that will be stored, both left and right of the decimal
-- point.  Precision must be value of 1 to 38 and it's default value is 18.
--
-- s = scale.  The number of decimal digits that will be stored right of the decimal point.  This number is
-- subtracted from p to determine the maximum number of digits to the left of the decimal point.  Scale must
-- be a value of 0 to p and can only be specified if p is specified.  It's default value is 0.
--
-- This example creates a table using decimals (could have just as easily been numeric) of varying precision
-- and scale (specified and using the defaults).  It populates it with some trivial data to illustrate that
-- rounding is performed then the number of digits to the right of the decimal point exceed the scale.
-- It queries the data and uses sp_help to describe the table.  The last part of the example shows an overflow 
-- error that will be raised when the number of digits to the left of the decimal point exceeds precision - scale.
--
DROP TABLE IF EXISTS dbo.my_decimal_values;

CREATE TABLE dbo.my_decimal_values (
  my_decimal_9_2        DECIMAL(9,2),    /* Storage 5 bytes  - <7 digits>.<2 digits>*/
  my_decimal_18_0       DECIMAL,         /* Storage 9 bytes  - <18 digits>.<0 digits>*/
  my_decimal_28_0       DECIMAL(28),     /* Storage 13 bytes - <28 digits>.<0 digits>*/
  my_decimal_38_10      DECIMAL(38,10),  /* Storage 17 bytes - <28 digits>.<10 digits>*/
);

GO

BEGIN TRANSACTION

INSERT INTO dbo.my_decimal_values(
  my_decimal_9_2,
  my_decimal_18_0,
  my_decimal_28_0,
  my_decimal_38_10
) VALUES (
  199.4455,         /* Exceeds scale - rounded to 2DP */
  1000.99,          /* Exceeds scale - rounded to 0DP */
  800000,
  5777.11112
);

COMMIT TRANSACTION

GO

SELECT * FROM dbo.my_decimal_values;

GO

sp_help my_decimal_values

GO

--
-- Arithmetic overflow example
--
DECLARE @myDecimalP5D2  DECIMAL(5,2);
BEGIN TRY
  SET @myDecimalP5D2 = 1000;
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