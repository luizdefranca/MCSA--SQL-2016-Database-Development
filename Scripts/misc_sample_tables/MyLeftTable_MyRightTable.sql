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
