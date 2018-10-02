-- Inline table-valued function
DROP FUNCTION IF EXISTS dbo.getDepartmentEmployees;
GO

CREATE FUNCTION dbo.getDepartmentEmployees(
  @department_id  AS  INT
) 
RETURNS TABLE
AS
RETURN (
  SELECT employee_id,
         CONCAT(first_name, ' ', last_name) AS employee_name,
         hire_date
    FROM ora_hr.employees
   WHERE department_id = @department_id
);
GO

SELECT *
  FROM dbo.getDepartmentEmployees(100);
GO

-- Multi-statement table-valued function
DROP FUNCTION IF EXISTS dbo.getDepartmentMembers;
GO

CREATE OR ALTER FUNCTION dbo.getDepartmentMembers (
  @department_id  AS  INT
) 
RETURNS @memberTable TABLE (
  department_role   VARCHAR(50),
  employee_id       INT,
  employee_name     VARCHAR(250),
  hire_date         DATE
)
AS
BEGIN

  --Manager
  INSERT @memberTable
  SELECT 'MANAGER' AS department_role,
         e.employee_id,
         CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
         e.hire_date
    FROM ora_hr.departments d
    JOIN ora_hr.employees e
      ON d.manager_id = e.employee_id
   WHERE d.department_id = @department_id;
  
  --Employees
  INSERT @memberTable
  SELECT 'EMPLOYEE' AS department_role, 
         employee_id,
         CONCAT(first_name, ' ', last_name) AS employee_name,
         hire_date
    FROM ora_hr.employees
   WHERE department_id = @department_id;

  RETURN;

END;
GO

SELECT *
  FROM dbo.getDepartmentMembers(100);
GO

SELECT *
  FROM ora_hr.departments AS d
  CROSS APPLY dbo.getDepartmentEmployees(d.department_id) AS e
 WHERE department_id = 100;

SELECT *
  FROM ora_hr.departments AS d
  CROSS APPLY dbo.getDepartmentMembers(d.department_id) AS e
 WHERE d.department_id = 100
   AND e.department_role = 'EMPLOYEE';