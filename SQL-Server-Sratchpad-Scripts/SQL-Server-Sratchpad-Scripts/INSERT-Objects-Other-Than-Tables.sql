--
-- Insert into objects other than tables
--
DROP TABLE IF EXISTS dbo.insert_test_tab;

CREATE TABLE dbo.insert_test_tab(
  col1  INT,
  col2  VARCHAR(100)
);
GO

--
-- Insert into a view
--
CREATE OR ALTER VIEW dbo.insert_test_vw
AS
SELECT col1 AS view_col1, col2 AS view_col2  
  FROM dbo.insert_test_tab;
GO

BEGIN TRANSACTION

INSERT INTO dbo.insert_test_vw(view_col1, view_col2)
OUTPUT inserted.view_col1 AS output_view_col1, inserted.view_col2 AS output_view_col2 
SELECT employee_id, last_name
  FROM ora_hr.employees
 WHERE department_id = 50
 ORDER BY last_name
 OFFSET 1 ROW FETCH NEXT 3 ROWS ONLY;

COMMIT TRANSACTION

SELECT * FROM dbo.insert_test_tab;
GO

--
-- Inserting into a table variable
--
DECLARE @my_table TABLE(
  col1   INT  NOT NULL,
  col2   VARCHAR(100) 
);

INSERT TOP(3) INTO @my_table(col1, col2)
OUTPUT inserted.col1 AS temp_col1, inserted.col2 AS temp_col2
SELECT employee_id, first_name
  FROM ora_hr.employees
 WHERE department_id = 50
 ORDER BY employee_id ASC;
 GO

