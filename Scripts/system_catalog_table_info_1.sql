--
-- https://stackoverflow.com/questions/17173260/check-if-extended-property-description-already-exists-before-adding
--
SELECT *
  FROM sys.columns
 WHERE object_id=OBJECT_ID('MyEmployees');
 

--
-- Check of a table is a Heap or a B-Tree
--
SELECT t.name AS table_name,
       p.partition_number,
   	   p.rows,
       CASE p.index_id
		     WHEN 1 THEN 'Heap'
		     WHEN 2 THEN 'Clustered Index/B-Tree'
		     WHEN 3 THEN 'Non-Clustered Index/B-Tree'
	     END partition_type
  FROM sys.tables AS t
  JOIN sys.partitions AS p
    ON t.object_id = p.object_id
 WHERE t.name = 'departments'; 
 
--
-- Check if the table has a clustered index
--
SELECT t.name      AS table_name,
       i.name      AS index_name,
	   i.type_desc AS index_type,
	   i.index_id,
	   ic.* 
  FROM sys.tables AS t
  JOIN sys.indexes AS i
    ON t.object_id = i.object_id
 WHERE t.name = 'departments'; 