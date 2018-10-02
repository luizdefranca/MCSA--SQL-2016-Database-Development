--
-- Basic syntax
--
DROP TABLE IF EXISTS dbo.employees2;

SELECT *
  INTO dbo.employees2
  FROM ora_hr.employees
 WHERE department_id = 50;

GO

SELECT *
  FROM dbo.employees2;

--
-- Update a single column
--
UPDATE dbo.employees2
   SET hire_date = GETDATE()
 WHERE employee_id = 120;

--
-- Updating multiple columns
--
UPDATE dbo.employees2
   SET salary += 100,
       commission_pct = 0.2
 WHERE employee_id = 127;

--
-- Using the TOP clause without an ORDER BY
--
UPDATE TOP (5) dbo.employees2
   SET salary *= 1.05;

--
-- Using the TOP clause with an ORDER BY (note: can't alias employees2
-- in this syntax)
--
UPDATE dbo.employees2
   SET salary *= 1.05
  FROM (SELECT TOP(5) employee_id
          FROM dbo.employees2
         ORDER BY salary ASC) AS lse
 WHERE employees2.employee_id = lse.employee_id;
 
--
-- Specify a subquery in the SET clause
--
UPDATE dbo.employees2  
   SET salary = (SELECT MAX(salary)  / 2
                   FROM dbo.employees2 AS he
                  WHERE employees2.department_id = he.department_id)
 WHERE salary = (SELECT MIN(salary)
                   FROM dbo.employees2);

--
-- Updating rows just using default values
--
DROP TABLE IF EXISTS dbo.default_test;

CREATE TABLE dbo.default_test (
  col1  INT NOT NULL CONSTRAINT dt_pk PRIMARY KEY,
  col2  VARCHAR(100) CONSTRAINT dt_col2_default DEFAULT 'My Default Value'
);
GO

INSERT INTO dbo.default_test VALUES (1, 'One'), (2, NULL), (3, DEFAULT);

SELECT * FROM dbo.default_test;

UPDATE dbo.default_test SET col2 = DEFAULT WHERE col1 = 2;

SELECT * FROM dbo.default_test;
GO