-- -----------------------------------------------------------------------------------------
--
-- MyLeftTable and MyRightTable 
--
DROP TABLE IF EXISTS dbo.MyLeftTable;
DROP TABLE IF EXISTS dbo.MyRightTable;

CREATE TABLE dbo.MyLeftTable(
  l_id     INT            NOT NULL,
  l_value  VARCHAR(50)    NOT NULL,
  CONSTRAINT MyLeftTable_PK PRIMARY KEY (l_id)
);  

CREATE TABLE dbo.MyRightTable(
  r_id     INT            NOT NULL,
  r_value  VARCHAR(50)   NOT NULL,
  r_l_id   INT,
  CONSTRAINT MyRightTable_PK PRIMARY KEY (r_id)
);

INSERT INTO dbo.MyLeftTable(l_id, l_value) VALUES (1, 'L One');
INSERT INTO dbo.MyLeftTable(l_id, l_value) VALUES (2, 'L Two');
INSERT INTO dbo.MyLeftTable(l_id, l_value) VALUES (3, 'L Three');
INSERT INTO dbo.MyRightTable(r_id, r_value) VALUES (1, 'R One');
INSERT INTO dbo.MyRightTable(r_id, r_value) VALUES (2, 'R Two');
INSERT INTO dbo.MyRightTable(r_id, r_value, r_l_id) VALUES (3, 'R L Three', 3);

COMMIT;

-- -----------------------------------------------------------------------------------------
--
-- MySimpleProducts
--
DROP TABLE IF EXISTS dbo.MySimpleProducts;

CREATE TABLE dbo.MySimpleProducts(
  p_id       INT           NOT NULL,
  p_name     VARCHAR(50)   NOT NULL,
  p_colour   VARCHAR(10)   NOT NULL,
  p_cost     NUMERIC(7,2)  NOT NULL,
  CONSTRAINT MySimpleProducts_PK PRIMARY KEY (p_id)
);

INSERT INTO dbo.MySimpleProducts(p_id, p_name, p_colour, p_cost) VALUES (1 , 'P1'  , 'RED'  , 123);
INSERT INTO dbo.MySimpleProducts(p_id, p_name, p_colour, p_cost) VALUES (2 , 'P2'  , 'BLUE' , 207);
INSERT INTO dbo.MySimpleProducts(p_id, p_name, p_colour, p_cost) VALUES (3 , 'P3'  , 'GREEN', 308);
INSERT INTO dbo.MySimpleProducts(p_id, p_name, p_colour, p_cost) VALUES (4 , 'P4'  , 'BLUE' , 487);
INSERT INTO dbo.MySimpleProducts(p_id, p_name, p_colour, p_cost) VALUES (5 , 'P5'  , 'RED'  , 501);
INSERT INTO dbo.MySimpleProducts(p_id, p_name, p_colour, p_cost) VALUES (6 , 'P6'  , 'RED'  , 649);
INSERT INTO dbo.MySimpleProducts(p_id, p_name, p_colour, p_cost) VALUES (7 , 'P7'  , 'BLUE' , 735);
INSERT INTO dbo.MySimpleProducts(p_id, p_name, p_colour, p_cost) VALUES (8 , 'P8'  , 'GREEN', 828);
INSERT INTO dbo.MySimpleProducts(p_id, p_name, p_colour, p_cost) VALUES (9 , 'P9'  , 'BLUE' , 991);
INSERT INTO dbo.MySimpleProducts(p_id, p_name, p_colour, p_cost) VALUES (10, 'P10' , 'RED'  , 1023);
INSERT INTO dbo.MySimpleProducts(p_id, p_name, p_colour, p_cost) VALUES (11, 'P102', 'ROSE GOLD'  , 8888);
