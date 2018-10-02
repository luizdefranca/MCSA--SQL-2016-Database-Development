--
-- Capturing the results of the update statement
--
DECLARE @results TABLE(
  employee_id  INT,
  old_salary   NUMERIC(10,4),
  new_salary   NUMERIC(10,4)
);

UPDATE ora_hr.employees
   SET salary += 100
OUTPUT inserted.employee_id,
       deleted.salary,
       inserted.salary
  INTO @results
 WHERE department_id = 90;

SELECT * FROM @results;
GO

 