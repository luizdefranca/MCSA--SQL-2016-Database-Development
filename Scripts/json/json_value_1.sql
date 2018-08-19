--
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/isjson-transact-sql?view=sql-server-2017
--
--
-- JSON_VALUE extracts a scalar value from a JSON string.  To extract an object
-- or an array from a JSON string instead of a scalar value use JSON_QUERY.
--
-- Syntax: JSON_VALUE(<expression>, <path>)
--
DECLARE @jsonInfo NVARCHAR(MAX)

SET @jsonInfo=N'{  
     "info":{    
       "type":1,  
       "address":{    
         "town":"Bristol",  
         "county":"Avon",  
         "country":"England"  
       },  
       "tags":["Sport", "Water polo"]  
    },  
    "type":"Basic"  
 }' 

SELECT JSON_VALUE(@jsonInfo, '$.info.address.town') AS town,
       JSON_VALUE(@jsonInfo, '$.info.tags[1]') AS second_tag,
	   JSON_VALUE(@jsonInfo, '$.type') AS standalone_type,
	   JSON_VALUE(@jsonInfo, '$.info.type') AS info_type;