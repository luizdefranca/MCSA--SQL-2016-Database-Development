--
-- Insert from other tables
--
DROP TABLE IF EXISTS dbo.insert_test_tab;

CREATE TABLE dbo.insert_test_tab(
  col1  INT,
  col2  VARCHAR(100)
);
GO

--
-- Simple
--
BEGIN TRANSACTION

INSERT INTO dbo.insert_test_tab(col1, col2)
SELECT employee_id, first_name + ' ' + last_name AS employee_name
  FROM ora_hr.employees
 WHERE department_id = 10;

COMMIT TRANSACTION

SELECT * FROM dbo.insert_test_tab;
GO

--
-- Using a TOP
--
BEGIN TRANSACTION

DELETE FROM dbo.insert_test_tab;

INSERT TOP(5) INTO dbo.insert_test_tab(col1, col2)
SELECT employee_id, first_name + ' ' + last_name AS employee_name
  FROM ora_hr.employees
 WHERE department_id = 50
 ORDER BY employee_id ASC;

COMMIT TRANSACTION

SELECT * FROM dbo.insert_test_tab;
GO

--
-- As above using OUTPUT to display the rows inserted into insert_test_tab
-- instead of the subsequent select statement
--
BEGIN TRANSACTION

DELETE FROM dbo.insert_test_tab;

INSERT TOP(5) INTO dbo.insert_test_tab(col1, col2)
OUTPUT inserted.col1 AS output_col1, inserted.col2 AS output_col2
SELECT employee_id, first_name + ' ' + last_name AS employee_name
  FROM ora_hr.employees
 WHERE department_id = 50
 ORDER BY employee_id ASC;

COMMIT TRANSACTION
GO

--
-- Using a WITH common table expression (CTE) to define the data
--
BEGIN TRANSACTION

DELETE FROM dbo.insert_test_tab;

WITH my_emps AS (
      SELECT employee_id, 
             CONCAT(first_name, ' ', last_name) AS employee_name
        FROM ora_hr.employees
       WHERE department_id = 50
       ORDER BY employee_id
       OFFSET 5 ROWS FETCH NEXT 4 ROWS ONLY
    )
INSERT INTO dbo.insert_test_tab(col1, col2)
OUTPUT inserted.col1 AS with_col1, inserted.col2 with_col2
SELECT employee_id, employee_name
  FROM my_emps;

COMMIT TRANSACTION
GO

--
-- Using the EXECUTE clause to call a stored procedure that contains the SELECT statment
--
CREATE OR ALTER PROCEDURE dbo.getEmployeesForInsert(
  @department_id  AS  INT
)
AS
  SET NOCOUNT ON 
  SELECT employee_id, 'From Procedure ' + last_name
    FROM ora_hr.employees
   WHERE department_id = @department_id
   ORDER BY employee_id
   OFFSET 0 ROWS FETCH FIRST 3 ROWS ONLY;
GO

BEGIN TRANSACTION

DELETE FROM dbo.insert_test_tab;

INSERT INTO dbo.insert_test_tab(col1, col2)
EXECUTE dbo.getEmployeesForInsert @department_id = 50;

--Can't use OUTPUT with INSERT .. EXECUTE so back to SELECT...
SELECT * FROM dbo.insert_test_tab;

COMMIT TRANSACTION
GO


