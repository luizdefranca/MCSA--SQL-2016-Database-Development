--
-- https://stackoverflow.com/questions/17173260/check-if-extended-property-description-already-exists-before-adding
--
SELECT *
  FROM sys.columns
 WHERE object_id=OBJECT_ID('MyEmployees');