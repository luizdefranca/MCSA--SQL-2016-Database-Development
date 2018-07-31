--
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/extended-properties-catalog-views-sys-extended-properties?view=sql-server-2017
--
-- This example queries the SYS.EXTENDED_PROPERTIES system catalog view to list the Captions (Comments) for the dbo.MyEmployees table
-- (I should have just used joins instead of the subquery then wouldn't have needed to call the OBJECT_NAME function)
--
SELECT CASE ep.class
         WHEN 1 THEN
           CASE WHEN sc.column_id IS NULL THEN 'TABLE' ELSE 'COLUMN' END    
         WHEN 7 THEN
           'INDEX'
       END                      AS comment_on,
       OBJECT_NAME(ep.major_id) AS table_name, 
       sc.name                  AS column_name,
       ix.name                  AS index_name,
       ep.value                 AS comment       
  FROM sys.extended_properties AS ep
  LEFT JOIN sys.columns AS sc
    ON ep.class    = 1
   AND ep.major_id = sc.object_id    
   AND ep.minor_id = sc.column_id
  LEFT JOIN sys.indexes AS ix
    ON ep.class    = 7
   AND ep.major_id = ix.object_id
   AND ep.minor_id = ix.index_id
 WHERE ep.name = 'Caption'
   AND ep.major_id = (SELECT object_id
                        FROM sys.schemas s
                        JOIN sys.tables t
                          ON s.schema_id = t.schema_id
                       WHERE s.name = 'dbo'
                         AND t.name = 'MyEmployees')
 ORDER BY table_name ASC, comment_on DESC;

--
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-functions/sys-fn-listextendedproperty-transact-sql?view=sql-server-2017
--
-- Alternative to the above using the FN_LISTEXTENDEDPROPERTY table function.
--
SELECT * 
  FROM fn_listextendedproperty(
         N'Caption',
         N'Schema', 'dbo',
         N'Table', 'MyEmployees',
         default, default
       )
 UNION ALL       
SELECT * 
  FROM fn_listextendedproperty(
         N'Caption',
         N'Schema', 'dbo',
         N'Table', 'MyEmployees',
         N'Column', default
       )
 UNION ALL
SELECT * 
  FROM fn_listextendedproperty(
         N'Caption',
         N'Schema', 'dbo',
         N'Table', 'MyEmployees',
         N'Index', default
       );     