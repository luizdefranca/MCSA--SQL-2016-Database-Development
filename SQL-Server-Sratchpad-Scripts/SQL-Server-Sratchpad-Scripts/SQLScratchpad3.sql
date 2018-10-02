DROP TABLE IF EXISTS dbo.my_product_details;
DROP TABLE IF EXISTS dbo.my_products;
DROP TABLE IF EXISTS dbo.my_years;

SELECT ROW_NUMBER() OVER(ORDER BY n DESC) AS year_no,
       YEAR(DATEADD(YEAR, n * -1, SYSDATETIME())) AS year_actual
  INTO dbo.my_years
  FROM dbo.getNums(1, 10);

SELECT *
  INTO dbo.my_products
  FROM (
       VALUES
         ('P1', 2, 3, 3),
         ('P2', 1, 2, 8),
         ('P3', 2, 8, 10)
       ) AS my_products(
         product_code, year_no_invented, year_no_released, year_no_withdrawn
       );

SELECT *
  INTO dbo.my_product_details
  FROM (
       VALUES
         ('P1', 'Red'),
         ('P3', 'Blue')
       ) AS my_product_details(
         product_code, colour
       );

select * from dbo.my_products;

--Query products that were invented in year 2 or released in year 2 or withdrawn in year 2
SELECT *
  FROM dbo.my_years AS y
  JOIN dbo.my_products AS p
    ON year_no = year_no_invented
    OR year_no = year_no_released
    OR year_no = year_no_withdrawn
 WHERE year_no = 2;

--Query products that were invented in year 1 or (released in year 1 and withdrawn in year 1) - correct
SELECT *
  FROM dbo.my_years AS y
  JOIN dbo.my_products AS p        
    ON year_no = year_no_invented  --<join condition 1>  |  <join condition 1>
    OR year_no = year_no_released  --<join condition 2>  |  OR <result of join condition 2 AND 3>
   AND year_no = year_no_withdrawn --<join condition 3>  |
 WHERE year_no = 2;

--Query products that were invented in year 1 or (released in year 1 and withdrawn in year 1) - incorrect
SELECT *
  FROM dbo.my_years AS y
  JOIN dbo.my_products AS p
    ON year_no = year_no_invented  --<join condition 1>  |
   AND year_no = year_no_withdrawn --<join condition 2>  | <result of join condition 1 AND 2>
    OR year_no = year_no_released  --<join condition 3>  | OR <join condition 3>
 WHERE year_no = 2;

 --Query products that were invented in year 1 or (released in year 1 and withdrawn in year 1) - correct ()
SELECT *
  FROM dbo.my_years AS y
  JOIN dbo.my_products AS p        
    ON year_no = year_no_invented        --<join condition 1>  |  <join condition 1>
    OR (    year_no = year_no_released   --<join condition 2>  |  OR <result of join condition 2 AND 3>
        AND year_no = year_no_withdrawn) --<join condition 3>  |
 WHERE year_no = 2;

 SELECT * FROM dbo.my_products;

SELECT *
  FROM dbo.my_years
  JOIN dbo.my_products
    ON year_no = year_no_invented   --<join condition 1>  |
   AND year_no = year_no_released   --<join condition 2>  |  <result of join condition 1 and 2>
    OR year_no = year_no_released   --<join condition 3>  |  OR
   AND year_no = year_no_withdrawn; --<join condition 4>  |  <result of join conditiion 3 and 4>


SELECT *
  FROM dbo.my_years
  JOIN dbo.my_products
    ON (    year_no = year_no_invented    --<join condition 1>  |
        AND year_no = year_no_released)   --<join condition 2>  |  <result of join condition 1 and 2>
    OR (    year_no = year_no_released    --<join condition 3>  |  OR
        AND year_no = year_no_withdrawn); --<join condition 4>  |  <result of join conditiion 3 and 4>

