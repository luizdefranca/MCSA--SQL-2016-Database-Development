--
-- Handling default values
--
DROP TABLE IF EXISTS dbo.insert_test_tab;

CREATE TABLE dbo.insert_test_tab(
  col1  INT,
  col2  VARCHAR(100) CONSTRAINT itt_col2_default DEFAULT ('My Default')
);
GO

BEGIN TRANSACTION

-- Default value
INSERT INTO dbo.insert_test_tab(col1) VALUES (1);

-- Explicit non-NULL value
INSERT INTO dbo.insert_test_tab(col1, col2) VALUES (2, 'Explicit Value');

-- Explicit NULL
INSERT INTO dbo.insert_test_tab(col1, col2) VALUES(3, NULL);

COMMIT TRANSACTION

SELECT * FROM dbo.insert_test_tab;
GO
