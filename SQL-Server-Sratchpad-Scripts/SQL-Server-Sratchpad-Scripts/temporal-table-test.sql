--
-- This script will take about 20 seconds to run because of the sleeps
--
-- Drop.  Versioning has to be turned off to allow the table to be dropped
--
IF OBJECT_ID('cc.temporal_test_table', N'U') IS NOT NULL
BEGIN
  IF OBJECTPROPERTY(OBJECT_ID('cc.temporal_test_table', N'U'), N'TableTemporalType') = 2
    ALTER TABLE cc.temporal_test_table
      SET (SYSTEM_VERSIONING = OFF);

  DROP TABLE IF EXISTS history.temporal_test_table_history, cc.temporal_test_table;

END;

--
-- Create.  The versioning columns can be hidden.
--
CREATE TABLE cc.temporal_test_table
   ( col1           INT  IDENTITY 
                         CONSTRAINT ttt_id_nn NOT NULL
                         CONSTRAINT ttt_pk PRIMARY KEY NONCLUSTERED
   , col2           VARCHAR(50)
   , sysstart       DATETIME2(0) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL
   , sysend         DATETIME2(0) GENERATED ALWAYS AS ROW END   HIDDEN NOT NULL
   , PERIOD FOR SYSTEM_TIME(sysstart, sysend)
   ) 
   WITH (
     SYSTEM_VERSIONING = ON (HISTORY_TABLE = history.temporal_test_table_history)
   );      

GO

--
-- Insert Dummy Data
--         
INSERT INTO cc.temporal_test_table(col2)
VALUES ('Red'), ('Blue'), ('Yellow'), ('Green'), ('Purple');

--
-- Select *.  Note that the sysstart and sysend columns are not returned...
--
SELECT * FROM cc.temporal_test_table;

--
-- But they can be explicitly selected
--
SELECT col1, col2, sysstart, sysend FROM cc.temporal_test_table;

--
-- Nothing in the history table yet
--
SELECT * FROM history.temporal_test_table_history;

--
-- Do an update (delay 5 seconds)
--
WAITFOR DELAY '00:00:03';
DECLARE @beforeRedOrangeUpdate DATETIME2 = SYSDATETIME();
WAITFOR DELAY '00:00:02';

UPDATE cc.temporal_test_table 
   SET col2 = 'Orange' 
 WHERE col1 = 1;

--
-- Do a delete (delay 5 seconds)
--
WAITFOR DELAY '00:00:03';
DECLARE @beforeDeleteYellow DATETIME2 = SYSDATETIME();
WAITFOR DELAY '00:00:02';

DELETE FROM cc.temporal_test_table WHERE col1 = 3;

--
-- Alter the temporal table - add a column (also adds the column to the history
-- table - note that drop removes the column from the history table)
--
ALTER TABLE cc.temporal_test_table
  ADD col3 DATE;

--
-- Do an update (delay 5 seconds - each update)
--
WAITFOR DELAY '00:00:03';
UPDATE cc.temporal_test_table 
   SET col3 = '2018-01-01'
 WHERE col1 = 1;

WAITFOR DELAY '00:00:03';
DECLARE @beforeUpdateNewDate DATETIME2 = SYSDATETIME();
WAITFOR DELAY '00:00:02';

UPDATE cc.temporal_test_table 
   SET col3 = '2018-06-23'
 WHERE col1 = 1;

--
-- Query the temporal table at different times
--
SELECT t.*, 'NOW' AS test
  FROM cc.temporal_test_table AS t
 ORDER BY col1;

SELECT t.*, @beforeUpdateNewDate AS as_at, 'Before Date Update' AS test
  FROM cc.temporal_test_table 
   FOR SYSTEM_TIME AS OF @beforeUpdateNewDate AS t  --or e.g. '2018-09-21 11:26:20'
 ORDER BY col1;

SELECT t.*, @beforeDeleteYellow AS as_at, 'Before Delete Yellow' AS test
  FROM cc.temporal_test_table
  FOR SYSTEM_TIME AS OF @beforeDeleteYellow  AS t
ORDER BY col1;
 
SELECT t.*, @beforeRedOrangeUpdate AS as_at, 'Before Update Red to Orange' AS test
  FROM cc.temporal_test_table
   FOR SYSTEM_TIME AS OF @beforeRedOrangeUpdate AS t
 ORDER BY col1;
GO

--
-- Or query the history table
--
SELECT * FROM history.temporal_test_table_history ORDER BY col1 ASC;
GO

--
-- Or query the table FOR SYSTEM_TIME ALL
--
SELECT col1, col2, col3, sysstart, sysend
  FROM cc.temporal_test_table
   FOR SYSTEM_TIME ALL AS t
 ORDER BY col1, sysstart;
GO