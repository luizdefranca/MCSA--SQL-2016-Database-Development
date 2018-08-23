--
-- Money (money and smallmoney)
--
-- https://docs.microsoft.com/en-us/sql/t-sql/data-types/data-types-transact-sql?view=sql-server-2017
-- https://docs.microsoft.com/en-us/sql/t-sql/data-types/money-and-smallmoney-transact-sql?view=sql-server-2017
--
-- Data types that represent monetary or currency values.  The money and small money data types are accurate to
-- a ten-thousandth (4 DP) of the monetary units they represent.
-- 
-- The data types can use a currency symbol (see the docs for a list).  While you can specify the symbol SQL
-- server does not store any currency information associated with the symbol, it only stores the numeric value.
-- In the example below $49.99 = £49.99 when queried after the insert statement.
--
-- This example creates a table using the money data types and populates it will the lowest and
-- highest values of the permitted ranges.  It queries the data and uses sp_help to describe the table.
-- The last part of the example shows an overflow error.

DROP TABLE IF EXISTS dbo.my_money_values;

CREATE TABLE dbo.my_money_values (
  my_comment     VARCHAR(100) CONSTRAINT my_money_values_pk PRIMARY KEY,  
  my_money       MONEY,          /* Storage 8 bytes */
  my_smallmoney  SMALLMONEY      /* Storage 4 bytes */
);

EXEC sp_addextendedproperty
  @name = N'Caption',
  @value = 'My money values example table',  
  @level0type = N'Schema', @level0name = 'dbo',  
  @level1type = N'Table',  @level1name = 'my_money_values';

GO

BEGIN TRANSACTION

INSERT INTO dbo.my_money_values(
  my_comment,
  my_money, 
  my_smallmoney
) VALUES (
  'Range - low value',
  CAST(-922337203685477.5808 AS MONEY),
  CAST(-214748.3648 AS SMALLMONEY)
), (
  'Range - high value',
  CAST(922337203685477.5807  AS MONEY),
  CAST(214748.3647 AS SMALLMONEY)
), (
  'Dollar ($) Sign with value',
   $49.99,
   $19.49
), (
  'Pound (£) Sign with value',
   £49.99,
   £19.49 
);

COMMIT TRANSACTION

GO

SELECT * FROM dbo.my_money_values;

SELECT d.my_money AS my_dollars,
       p.my_money AS my_pounds,
	   CASE d.my_money - p.my_money WHEN 0 THEN 'Y' ELSE 'N' END AS are_equal,
	   d.my_smallmoney AS my_small_dollars,
	   p.my_smallmoney AS my_small_pounds,
	   CASE d.my_smallmoney - p.my_smallmoney WHEN 0 THEN 'Y' ELSE 'N' END AS are_also_equal
  FROM dbo.my_money_values AS d
  CROSS JOIN dbo.my_money_values AS p
 WHERE d.my_comment = 'Dollar ($) Sign with value'
   AND p.my_comment = 'Pound (£) Sign with value';

GO

sp_help [dbo.my_money_values]

GO

--
-- Arithmetic overflow example
--
DECLARE @mySmallMoney  SMALLMONEY;
BEGIN TRY
  SET @mySmallMoney = (
    SELECT my_smallmoney + 1
	  FROM dbo.my_money_values
	 WHERE my_comment = 'Range - high value'
  );
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