--
--
-- https://docs.microsoft.com/en-us/sql/xquery/xquery-language-reference-sql-server?view=sql-server-2017
-- https://docs.microsoft.com/en-us/sql/t-sql/xml/xml-data-type-methods?view=sql-server-2017
--
-- This is just random messing to get familiar with T-SQL and XQuery
--
DROP TABLE IF EXISTS dbo.xquery_example_1;

CREATE TABLE dbo.xquery_example_1 (
  xe1_name   VARCHAR(50) CONSTRAINT xe1_example_name_nn NOT NULL,
  xe1_xml    XML,
  CONSTRAINT xe1_pk PRIMARY KEY (xe1_name)  
);

INSERT INTO dbo.xquery_example_1 (
  xe1_name,
  xe1_xml
) VALUES 
  ('A,B (Elements)', 
   CAST('<a>
           <b>1</b>
		   <b>2</b>
		   <b>3</b>
		   <b>4</b>
		   <b>5</b>
		   <b>6</b>
		 </a>' AS XML)
  ),
  ('A,B,C (Elements and Attrbutes)', 
   CAST('<a>
           <b c="one">1</b>
		   <b c="two">2</b>
		   <b c="three">3</b>
		   <b c="four">4</b>
		   <b c="five">5</b>
		   <b c="six">6</b>
		 </a>' AS XML)
  );

SELECT xe1_xml.query(
        'for $i in /a/b
		return $i'
        )
  FROM dbo.xquery_example_1
 WHERE xe1_name = 'A,B (Elements)';

SELECT t2.b.query('.')
  FROM dbo.xquery_example_1
  CROSS APPLY xe1_xml.nodes('/a/b') AS t2(b);

DECLARE @x xml   
SET @x='<Root>  
    <row id="1"><name>Larry</name><oflw>some text</oflw></row>  
    <row id="2"><name>moe</name></row>  
    <row id="3" />  
</Root>'  
SELECT T.c.query('.') AS result  
FROM   @x.nodes('/Root/row') T(c)  
GO  


