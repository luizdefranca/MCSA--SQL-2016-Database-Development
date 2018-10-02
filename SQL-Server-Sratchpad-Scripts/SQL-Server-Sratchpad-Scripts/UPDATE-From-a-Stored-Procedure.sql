--
-- Update from a stored procedure
--
DROP TABLE IF EXISTS dbo.test_table;

CREATE TABLE dbo.test_table(
  col1   INT IDENTITY,
  col2   VARCHAR(100),
  col3   DATE,
  col4   DECIMAL(10,2) CONSTRAINT col4_default DEFAULT 0
);

INSERT INTO dbo.test_table(col2, col3)
     VALUES ('Red', '20100101'), ('Blue', '20140405');

GO

--
-- Procedure with only IN parameters
--
CREATE OR ALTER PROCEDURE dbo.update_test_table
  @col1  INT,
  @col2  VARCHAR(100),
  @col3  DATE = '19900101',
  @col4  DECIMAL(10,2) = 200
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE dbo.test_table
     SET col2 = @col2,
         col3 = @col3,
         col4 = @col4
   WHERE col1 = @col1;
END;
GO

SELECT * FROM dbo.test_table;

EXEC dbo.update_test_table
  @col1 = 1,
  @col2 = 'Yellow',
  @col3 = '20171231';

SELECT * FROM dbo.test_table;

EXEC dbo.update_test_table 2, 'Purple';

SELECT * FROM dbo.test_table;

--
-- Procedure with OUT (OUTPUT) parameters
--
CREATE OR ALTER PROCEDURE dbo.update_test_table_out
    @col1      INT,
    @col2      VARCHAR(100),
    @old_col2  VARCHAR(100) OUTPUT,
    @new_col2  VARCHAR(100) OUTPUT,
    @no_rows   INT          OUTPUT
AS
BEGIN

  DECLARE @tempResults TABLE(
    old_col2  VARCHAR(100),
    new_col2  VARCHAR(100)
  );

  UPDATE dbo.test_table  
     SET col2 = @col2
  OUTPUT deleted.col2, inserted.col2
    INTO @tempResults(old_col2, new_col2)
   WHERE col1 = @col1;

  SET @no_rows = @@ROWCOUNT;

  SET @old_col2 = (SELECT old_col2
                     FROM @tempResults);

  SET @new_col2 = (SELECT new_col2
                     FROM @tempResults);
END;
GO

DECLARE @old_val VARCHAR(100), 
        @new_val VARCHAR(100),
        @rows_affected INT;

EXEC dbo.update_test_table_out
  @col1 = 1,
  @col2 = 'Red',
  @no_rows  = @rows_affected OUTPUT,
  @old_col2 = @old_val       OUTPUT,
  @new_col2 = @new_val       OUTPUT;

SELECT @rows_affected AS rows_affected,
       @old_val       AS old_col2_value, 
       @new_val       AS new_col2_value;

SELECT * FROM dbo.test_table;
GO

--
-- Alternative to using OUTPUT table
--
CREATE OR ALTER PROCEDURE dbo.update_test_table_out2
  @col1      INT,
  @pct       DECIMAL(2,2),
  @old_col4  DECIMAL(10,2) OUTPUT,
  @new_col4  DECIMAL(10,2) OUTPUT
AS
 
  SET @old_col4 = (SELECT col4 
                     FROM dbo.test_table
                    WHERE col1 = @col1);

  UPDATE dbo.test_table  
     SET @new_col4 = col4 = col4 * (1 + @pct)
   WHERE col1 = @col1;
GO 

DECLARE @old_val  DECIMAL(10,2), @new_val  DECIMAL(10, 2);

SELECT * FROM dbo.test_table;

EXEC dbo.update_test_table_out2
  @col1 = 2,
  @pct = 0.1,
  @old_col4 = @old_val OUTPUT,
  @new_col4 = @new_val OUTPUT;

SELECT @old_val AS old_col4, @new_val AS new_col4;

SELECT * FROM dbo.test_table;
GO
