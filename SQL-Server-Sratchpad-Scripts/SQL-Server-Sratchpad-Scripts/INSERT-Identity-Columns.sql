--
-- Identity columns
--
DROP TABLE IF EXISTS dbo.insert_test_tab;

CREATE TABLE dbo.insert_test_tab(
  col1  INT  IDENTITY,
  col2  VARCHAR(100)
);
GO

BEGIN TRANSACTION

--Implicit column list (not good practice) just to show that the identify column is not
--implicitly referenced by the values
INSERT INTO dbo.insert_test_tab VALUES ('Implicit column list');

--Explicit column list
INSERT INTO dbo.insert_test_tab(col2) VALUES ('Explicit column list');

--Explicit insert into the identify column
SET IDENTITY_INSERT dbo.insert_test_tab ON 
INSERT INTO dbo.insert_test_tab(col1, col2) VALUES (3, 'Explicit identity');

--Note that this doesn't cause a problem for a subsequent insert
SET IDENTITY_INSERT dbo.insert_test_tab OFF
INSERT INTO dbo.insert_test_tab(col2) VALUES ('After explicit identity');

--Call the three different functions that return the value of the identity column
SELECT SCOPE_IDENTITY()                      AS l_scope_identity, 
       IDENT_CURRENT('dbo.insert_test_tab')  AS l_ident_current, 
       @@IDENTITY                            AS l_identity;

COMMIT TRANSACTION

SELECT * FROM dbo.insert_test_tab;
GO
