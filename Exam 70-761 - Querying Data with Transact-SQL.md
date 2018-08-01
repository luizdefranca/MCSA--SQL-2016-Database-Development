# Exam 70-761 - Querying Data with Transact-SQL

https://www.microsoft.com/en-us/learning/exam-70-761.aspx

## Manage data with Transaction-SQL (40-45%)

Topic|Progress
-----|--------
Create Transact-SQL SELECT queries|WIP
Query multiple tables by using joins|WIP
Implement functions and aggregate data|WIP
Modify data|WIP

### Create Transact-SQL SELECT queries

* Identify proper SELECT query structure
* Write specific queries to satisfy business requirements
* Construct results from multiple queries using set operators
* Distinguish between UNION and UNION ALL behavior
* Identify the query that would return expected results based on provided table structure and/or data

### Query multiple tables by using joins

* Write queries with join statements based on provided tables, data, and requirements
* Determine proper usage of INNER JOIN, LEFT/RIGHT/FULL OUTER JOIN, and CROSS JOIN
* Construct multiple JOIN operators using AND and OR
* Determine the correct results when presented with multi-table SELECT statements and source data
* Write queries with NULLs on joins

### Implement functions and aggregate data

* Construct queries using scalar-valued and table-valued functions
* Identify the impact of function usage to query performance and WHERE clauses argability
* Identify the differences between deterministic and non-deterministic functions; 
* Use built-in aggregate functions
* Use arithmetic functions, date-related functions, and system functions

### Modify data

* Write INSERT, UPDATE, and DELETE statements
* Determine which statements can be used to load data to a table based on its structure and constraints
* Construct Data Manipulation Language (DML) statements using the OUTPUT statement
* Determine the results of Data Definition Language (DDL) statements on supplied tables and data

## Program databases using Transact-SQL (25-30%)

Topic|Progress
-----|--------
Create database programmability objects by using Transact-SQL|TODO
Implement error handling and transactions|TODO
Implement data types and NULLs|TODO

### Create database programmability objects by using Transact-SQL 

* Create stored procedures, table-valued and scalar-valued user-defined functions, and views
* Implement input and output parameters in stored procedures
* Identify whether to use scalar-valued or table-valued functions
* Distinguish between deterministic and non-deterministic functions
* Create indexed views

### Implement error handling and transactions 

* Determine results of Data Definition Language (DDL) statements based on transaction control statements
* Implement TRY…CATCH error handling with Transact-SQL
* Generate error messages with THROW and RAISERROR
* Implement transaction control in conjunction with error handling in stored procedures

### Implement data types and NULLs 

* Evaluate results of data type conversions
* Determine proper data types for given data elements or table columns
* Identify locations of implicit data type conversions in queries
* Determine the correct results of joins and functions in the presence of NULL values
* Identify proper usage of ISNULL and COALESCE functions

## Query data with advanced Transact-SQL components (30-35%)

Topic|Progress
-----|--------
Query data by using subqueries and APPLY|TODO
Query data by using table expressions|TODO
Group and pivot data by using queries|TODO
Query temporal data and non-relational data|TODO

### Query data by using subqueries and APPLY 

* Determine the results of queries using subqueries and table joins
* Evaluate performance differences between table joins and correlated subqueries based on provided data and query plans
* Distinguish between the use of CROSS APPLY and OUTER APPLY
* Write APPLY statements that return a given data set based on supplied data

### Query data by using table expressions 

* Identify basic components of table expressions
* Define usage differences between table expressions and temporary tables
* Construct recursive table expressions to meet business requirements

### Group and pivot data by using queries 

* Use windowing functions to group and rank the results of a query
* Distinguish between using windowing functions and GROUP BY
* Construct complex GROUP BY clauses using GROUPING SETS, and CUBE
* Construct PIVOT and UNPIVOT statements to return desired results based on supplied data
* Determine the impact of NULL values in PIVOT and UNPIVOT queries

### Query temporal data and non-relational data 

* Query historic data by using temporal tables
* Query and output JSON data
* Query and output XML data


