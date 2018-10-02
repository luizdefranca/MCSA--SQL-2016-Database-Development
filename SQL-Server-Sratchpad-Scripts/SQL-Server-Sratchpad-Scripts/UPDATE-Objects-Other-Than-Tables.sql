--
-- Update a view 
--
CREATE OR ALTER VIEW dbo.dept50Employees
AS
  SELECT *
    FROM ora_hr.employees
   WHERE department_id = 50
  WITH CHECK OPTION;
GO

--Valid upate
BEGIN TRANSACTION

UPDATE dbo.dept50Employees
   SET last_name = 'Jones'
OUTPUT deleted.last_name AS old_last_name,
       inserted.last_name AS new_last_name
 WHERE employee_id = 120;

COMMIT TRANSACTION
GO

--Invalid update - fails the check option on the view
BEGIN TRY
  UPDATE dbo.dept50Employees
     SET department_id = 60
   WHERE employee_id = 120;
END TRY
BEGIN CATCH
  SELECT ERROR_NUMBER()  AS [error_number],
         ERROR_MESSAGE() AS [error_message];
END CATCH
GO

--
-- Specifying an alias.  
--
UPDATE e 
   SET e.salary = e.salary + d.department_id
  FROM ora_hr.departments AS d
  JOIN ora_hr.employees AS e
    ON d.department_id = e.department_id
 WHERE d.department_id = 50;

--
-- Specifying a table variable
--
DECLARE @mytable TABLE(
  col1  INT,
  col2  VARCHAR(100),
  col3  DATE
);

INSERT INTO @mytable(col1, col2, col3) 
     VALUES (1, 'Red', '20100101'), (2, 'Blue', '20120401');

UPDATE @mytable 
   SET col2 = 'Yellow', col3 = GETDATE()
OUTPUT deleted.col2  AS old_col2, deleted.col3 AS old_col3,
       inserted.col2 AS new_col2, inserted.col3 AS new_col3
 WHERE col1 = 2;

GO
