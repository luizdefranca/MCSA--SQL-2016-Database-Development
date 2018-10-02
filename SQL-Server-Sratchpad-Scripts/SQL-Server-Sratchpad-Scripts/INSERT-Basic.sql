--
-- Basic Syntax
--
DROP TABLE IF EXISTS dbo.insert_test_tab;

CREATE TABLE dbo.insert_test_tab(
  col1  INT,
  col2  VARCHAR(100)
);
GO

BEGIN TRANSACTION

-- Single row insert
INSERT INTO dbo.insert_test_tab(col1, col2) VALUES (1, 'One');

-- Multiple rows insert
INSERT INTO dbo.insert_test_tab(col1, col2) VALUES (2, 'Two'), (3, 'Three');

-- Inserting the columns in a different order than they are defined
INSERT INTO dbo.insert_test_tab(col2, col1) VALUES ('Four', 4);

COMMIT TRANSACTION

SELECT * FROM dbo.insert_test_tab;
GO

