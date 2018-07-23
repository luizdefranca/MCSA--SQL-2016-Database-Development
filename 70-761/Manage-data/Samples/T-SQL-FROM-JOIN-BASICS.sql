--
-- https://docs.microsoft.com/en-us/sql/t-sql/queries/from-transact-sql?view=sql-server-2017
--
--

-- -----------------------------------------------------------------------------------------
--
-- INNER JOIN 
--
-- Specifies all matching pairs of rows are returned. Discards unmatched rows from both  
-- tables.  When no join type is specified, this is the default. 

--
-- With the INNER keyword
--
SELECT m.productModelId, m.name productModelName,
       p.productId, p.name productName
  FROM SalesLT.ProductModel m
  INNER JOIN SalesLT.Product p
    ON m.productModelId = p.productModelId
 WHERE m.productModelId IN (3, 39, 40, 41);
 
--
-- Without the INNER keyword
--
SELECT m.productModelId, m.name productModelName,
       p.productId, p.name productName
  FROM SalesLT.ProductModel m
  JOIN SalesLT.Product p
    ON m.productModelId = p.productModelId
 WHERE m.productModelId IN (3, 39, 40, 41); 
 
-- -----------------------------------------------------------------------------------------
--
-- LEFT [OUTER] JOIN
-- 
-- Specifies that all rows from the left table not meeting the join condition are included 
-- in the result set, and output columns from the other table are set to NULL in addition 
-- to all rows returned by the inner join. 
--

--
-- With the OUTER keyword
--
-- Note that the predicate in the example is on the perserved table (left table) otherwise
-- it would negate the effect of the outer join.
--
SELECT m.productModelId, m.name productModelName,
       p.productId, p.name productName
  FROM SalesLT.ProductModel m
  LEFT OUTER JOIN SalesLT.Product p
    ON m.productModelId = p.productModelId
 WHERE m.productModelId IN (3, 39, 40, 41);
 
--
-- Without the OUTER keyword
--
SELECT m.productModelId, m.name productModelName,
       p.productId, p.name productName
  FROM SalesLT.ProductModel m
  LEFT JOIN SalesLT.Product p
    ON m.productModelId = p.productModelId
 WHERE m.productModelId IN (3, 39, 40, 41); 
 
-- -----------------------------------------------------------------------------------------
--
-- LEFT [OUTER] JOIN
-- 
-- Specifies all rows from the right table not meeting the join condition are included in 
-- the result set, and output columns that correspond to the other table are set to NULL, 
-- in addition to all rows returned by the inner join. 
--

--
-- With the OUTER keyword
--
SELECT m.productModelId, m.name productModelName,
       p.productId, p.name productName
  FROM SalesLT.Product p
  RIGHT OUTER JOIN SalesLT.ProductModel m 
    ON m.productModelId = p.productModelId
 WHERE m.productModelId IN (3, 39, 40, 41);
 
--
-- Without the OUTER keyword
--
SELECT m.productModelId, m.name productModelName,
       p.productId, p.name productName
  FROM SalesLT.Product p
  RIGHT JOIN SalesLT.ProductModel m 
    ON m.productModelId = p.productModelId
 WHERE m.productModelId IN (3, 39, 40, 41);
 
-- -----------------------------------------------------------------------------------------
--
-- FULL [OUTER] JOIN
-- 
-- Specifies that a row from either the left or right table that does not meet the join 
-- condition is included in the result set, and output columns that correspond to the other 
-- table are set to NULL.  This is in addition to all rows returned by the inner join. 
--

--
-- Customers LEFT OUT JOIN Addresses.  
--
SELECT c.customerId, c.firstName, c.lastName, a.addressId, a.addressLine1
  FROM SalesLT.Customer c
  LEFT JOIN SalesLT.CustomerAddress ca
    ON c.customerId = ca.customerId
  LEFT JOIN SalesLT.address a
    ON ca.addressId = a.addressId
 WHERE c.customerId IN (1, 29485);
 
--
-- (to save rewriting too much) Customers RIGHT OUTER JOIN Addresses
-- 
SELECT c.customerId, c.firstName, c.lastName, a.addressId, a.addressLine1
  FROM SalesLT.Customer c
 RIGHT JOIN SalesLT.CustomerAddress ca
    ON c.customerId = ca.customerId
 RIGHT JOIN SalesLT.address a
    ON ca.addressId = a.addressId
 WHERE a.addressId IN (1086, 1042);
 
--
-- Customers FULL OUTER JOIN Addresses
--
SELECT c.customerId, c.firstName, c.lastName, a.addressId, a.addressLine1
  FROM SalesLT.Customer c
  FULL JOIN SalesLT.CustomerAddress ca
    ON c.customerId = ca.customerId
   FULL JOIN SalesLT.address a
    ON ca.addressId = a.addressId
 WHERE a.addressId IN (1086, 1042)
    OR c.customerId IN (1, 29485);

-- -----------------------------------------------------------------------------------------
--
-- CROSS JOIN (prerequisite - T-SQL-MY-GENERIC-SAMPLE-TABLE.sql)
--  
-- Specifies the cross-product of two tables (cartesian join).
--

--
-- Cross produce of MyLeftTable and MyRightTable
--
SELECT l_id, r_id
  FROM dbo.MyLeftTable
  CROSS JOIN dbo.MyRightTable;
  
