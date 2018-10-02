DROP FUNCTION IF EXISTS dbo.getEmployeeName;
GO
CREATE FUNCTION dbo.getEmployeeName(
  @employee_id  INT
)
RETURNS VARCHAR(200)
AS
BEGIN
  RETURN (
    SELECT CONCAT(first_name, ' ', last_name)
      FROM ora_hr.employees
     WHERE employee_id = @employee_id
  );
END;
GO

SELECT * FROM ora_hr.departments;

SELECT department_id,
       department_name,
       dbo.getEmployeeName(manager_id) AS manager_name  
  FROM ora_hr.departments
 WHERE department_id IN (110, 120);

SELECT d.department_id,
       d.department_name,
       m.manager_name  
  FROM ora_hr.departments AS d
  CROSS APPLY (SELECT dbo.getEmployeeName(d.manager_id)) AS m(manager_name)
 WHERE d.department_id IN (90, 100, 110)
   AND (   m.manager_name LIKE 'Nancy%'
        OR m.manager_name LIKE 'Shelley%');
  

SELECT d.department_id,
       d.department_name,
       dbo.getEmployeeName(d.manager_id) AS manager_name
  FROM ora_hr.departments AS d
  JOIN ora_hr.employees AS e
    ON dbo.getEmployeeName(d.manager_id) = dbo.getEmployeeName(e.employee_id)
 WHERE d.department_id = 100
   AND dbo.getEmployeeName(d.manager_id) IS NOT NULL;

SELECT *
  FROM ora_hr.employees

SELECT employee_id,
       first_name + ' ' + last_name AS employee_name,
       ISNULL(commission_pct, 0)    AS commission_pct
  FROM ora_hr.employees
 WHERE employee_id IN (144, 145);