-- -----------------------------------------------------------------------------------------
--
-- MySimpleProducts
--
DROP TABLE IF EXISTS dbo.MySimpleProducts;

CREATE TABLE dbo.MySimpleProducts(
  p_id       INT           NOT NULL,
  p_name     VARCHAR(50)   NOT NULL,
  p_colour   VARCHAR(10)   ,
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
INSERT INTO dbo.MySimpleProducts(p_id, p_name, p_colour, p_cost) VALUES (12, 'P201', NULL  , 10000);
INSERT INTO dbo.MySimpleProducts(p_id, p_name, p_colour, p_cost) VALUES (13, 'P202', NULL  , 20000);
