--
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/create-table-transact-sql?view=sql-server-2017
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-addextendedproperty-transact-sql?view=sql-server-2017
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-functions/sys-fn-listextendedproperty-transact-sql?view=sql-server-2017
--
-- This example:
-- 1.  Creates two simple tables primary keys and foreign keys in different ways 
--     (including a self referencing foreign key).
-- 2.  Uses sp_addextendedproperty to create table and column comments
--
DROP TABLE IF EXISTS dbo.MyEmployees;
DROP TABLE IF EXISTS dbo.MyDepartments;
DROP INDEX IF EXISTS IX_MyEmployees_departmentId ON dbo.MyEmployees;
DROP INDEX IF EXISTS IX_MyEmployees_firstName_lastName ON dbo.MyEmployees;

--Parent table
CREATE TABLE dbo.MyDepartments(
  departmentId    INT         NOT NULL CONSTRAINT myDepartmentsPK PRIMARY KEY,
  departmentName  VARCHAR(30) NOT NULL
);

--Child table
CREATE TABLE dbo.MyEmployees(
  employeeId     INT          NOT NULL,
  firstName      VARCHAR(25)  NOT NULL,
  lastName       VARCHAR(25)  NOT NULL,
  departmentId   INT          CONSTRAINT MyEmployeesMyDepartmentsFK 
                                FOREIGN KEY REFERENCES dbo.MyDepartments(departmentId),
  managerId      INT,
  CONSTRAINT MyEmployeesPK 
    PRIMARY KEY (employeeId),
  CONSTRAINT MyEmployeesManagerFK 
    FOREIGN KEY (managerId) REFERENCES dbo.MyEmployees(employeeId)
);  

--Indexes (non-clustered - default)
CREATE INDEX IX_MyEmployees_departmentId 
    ON dbo.MyEmployees (departmentId);
    
CREATE INDEX IX_MyEmployees_firstName_lastName 
    ON dbo.MyEmployees (firstName, lastName);    

-- Table comments
EXEC sp_addextendedproperty
@name = N'Caption',
@value = 'My employees table',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table',  @level1name = 'MyEmployees';

-- Column comments
EXEC sp_addextendedproperty
@name = N'Caption',
@value = 'Unique identifier for the employee',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table',  @level1name = 'MyEmployees',  
@level2type = N'Column', @level2name = 'employeeId';  

EXEC sp_addextendedproperty
@name = N'Caption',
@value = 'Employee first name',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table',  @level1name = 'MyEmployees',  
@level2type = N'Column', @level2name = 'firstName';  

EXEC sp_addextendedproperty
@name = N'Caption',
@value = 'Employee last name',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table',  @level1name = 'MyEmployees',  
@level2type = N'Column', @level2name = 'lastName';  

--Index comments
EXEC sp_addextendedproperty
@name = N'Caption',
@value = 'Index on the departmentId column',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table',  @level1name = 'MyEmployees',  
@level2type = N'Index',  @level2name = 'IX_MyEmployees_departmentId';  

EXEC sp_addextendedproperty
@name = N'Caption',
@value = 'Daft index just as an exmple on firstName and lastName',  
@level0type = N'Schema', @level0name = 'dbo',  
@level1type = N'Table',  @level1name = 'MyEmployees',  
@level2type = N'Index',  @level2name = 'IX_MyEmployees_firstName_lastName';  

-- List table comments
SELECT * 
  FROM fn_listextendedproperty(
         N'Caption',
         N'Schema', 'dbo',
         N'Table', 'MyEmployees',
         default, default
       );

-- List column comments
SELECT * 
  FROM fn_listextendedproperty(
         N'Caption',
         N'Schema', 'dbo',
         N'Table', 'MyEmployees',
         N'Column', default
       );
      
--Insert some data
INSERT INTO dbo.MyDepartments(departmentId, departmentName) VALUES (1, 'HR');
INSERT INTO dbo.MyEmployees(employeeId, firstName, lastName, departmentId) VALUES (1, 'John', 'Smith', 1);

--Select from the tables
SELECT departmentName, firstName, lastName  
  FROM dbo.MyDepartments AS d 
  JOIN dbo.MyEmployees AS e
    ON d.departmentId = e.departmentId
 ORDER BY departmentName ASC;
