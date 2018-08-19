--
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/openjson-transact-sql?view=sql-server-2017
--
DECLARE @json NVARCHAR(MAX)
SET @json =  
N'{
  "files":[
    {
      "name": "T-SQL-CREATE-TABLE-BASICS.sql", 
      "tags": ["CREATE TABLE", "CREATE INDEX", "sp_addextendedproperty", "fn_listextendedproperty"],
      "NPPP": {
        "project": "T-SQL Samples", 
        "folders": ["CREATE TABLE"] 
      }
    },
    {
      "name": "T-SQL-FROM-JOIN-APPLY.sql", 
      "tags": ["Joins", "APPLY"],
      "NPPP": {
        "project": "T-SQL Samples", 
        "folders": ["SELECT"] 
      }
    },    
    {
      "name": "T-SQL-FROM-JOIN-BASICS.sql", 
      "tags": ["Joins", "APPLY"],
      "NPPP": {
        "project": "T-SQL Samples", 
        "folders": ["SELECT"] 
      }
    },   
    {
      "name": "T-SQL-FROM-PIVOT.sql", 
      "tags": ["PIVOT"],
      "NPPP": {
        "project": "T-SQL Samples", 
        "folders": ["SELECT"] 
      }
    },       
    {
      "name": "T-SQL-MY-GENERIC-SAMPLE-TABLES.sql", 
      "tags": ["SETUP", "CREATE TABLE"],
      "NPPP": {
        "project": "T-SQL Samples", 
        "folders": ["SETUP"] 
      }
    },      
    {
      "name": "T-SQL-ORDER-BY-OFFSET-FETCH.sql", 
      "tags": ["ORDER BY", "OFFSET FETCH", "Row Limiting Clause"],
      "NPPP": {
        "project": "T-SQL Samples", 
        "folders": ["SELECT"] 
      }
    },   
    {
      "name": "T-SQL-QUERY-EXTENDED-PROPERTIES.sql", 
      "tags": ["fn_listextendedproperty", "EXTENDED_PROPERTIES", "Extended Properties", "System Catalog", "Data Dictionary"],
      "NPPP": {
        "project": "T-SQL Samples", 
        "folders": ["DATA DICTIONARY (SYSTEM CATELOG)"] 
      }
    },     
    {
      "name": "T-SQL-QUERY-TABLE-INFO.sql", 
      "tags": ["System Catalog", "Data Dictionary"],
      "NPPP": {
        "project": "T-SQL Samples", 
        "folders": ["DATA DICTIONARY (SYSTEM CATELOG)"] 
      }
    }       
  ]
}'  

SELECT *  
FROM OPENJSON(@json, '$.files');

--
-- File tags 
--
SELECT file_name, tag
  FROM 
    OPENJSON(@json, '$.files') 
    WITH (
        file_name  VARCHAR(200)  '$.name',
        tags       NVARCHAR(MAX) AS JSON
    ) AS file_tab
  CROSS APPLY 
    OPENJSON(file_tab.tags)
    WITH (
      tag   VARCHAR(200)  '$'
    ) AS tag_tab;
