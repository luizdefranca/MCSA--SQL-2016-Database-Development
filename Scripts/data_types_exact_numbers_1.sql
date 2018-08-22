--
-- https://docs.microsoft.com/en-us/sql/t-sql/data-types/data-types-transact-sql?view=sql-server-2017
--
--
-- Exact numbers
--
DROP TABLE IF EXISTS dbo.my_money_values;
DROP TABLE IF EXISTS dbo.my_decimal_values;

--
-- Integers
--
-- Exact number data types that use integer data.  To save space use the smallest data type that
-- can reliably contain all possible values.  For example TINYINT would be suitable for a person's
-- age but not for the number of days in a year.
--
DROP TABLE IF EXISTS dbo.my_int_values;

CREATE TABLE dbo.my_int_values(
  my_comment     VARCHAR(100), 
  my_bigint      BIGINT,        /* Storage 8 bytes */
  my_int         INT,           /* Storage 4 bytes */
  my_smallint    SMALLINT,      /* Storage 2 bytes */
  my_tinyint     TINYINT        /* Storage 1 byte  */
);

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


CREATE TABLE dbo.my_money_values (
  my_comment     VARCHAR(100),  /* Storage 8 bytes */
  my_money       MONEY,
  my_smallmoney  SMALLMONEY
)

--decimal and numeric are synonyms and can be used interchangeably
CREATE TABLE dbo.my_decimal_values (
  my_max_precision1         DECIMAL(38),
  my_max_precision2         NUMERIC(38,0),
  my_precision_and_scale1   DECIMAL(10,5),
  my_precision_and_scale2   NUMERIC(5,5)
);

GO



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
);

INSERT INTO dbo.my_decimal_values(
  my_max_precision1,
  my_max_precision2,
  my_precision_and_scale1,
  my_precision_and_scale2
) VALUES (
  123456789012345678901234567890123456,
  654321098765432109876543210987654321,
  54321.12345,
  0.12345
), (
  NULL,
  NULL,
  54321.12312312,
  1.2321
);


COMMIT TRANSACTION

GO

SELECT * FROM dbo.my_money_values;

SELECT * FROM dbo.my_decimal_values;