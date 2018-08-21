--
-- https://docs.microsoft.com/en-us/sql/t-sql/functions/configuration-functions-transact-sql?view=sql-server-2017
--
-- Scalar functions that return information about the current configuration option settings.  I've only
-- included the ones that I think are immediately useful, there are more.
--

--
-- @@DATEFIRST returns the current value DATEFIRST, for a specific session.  DATEFIRST is an integer
-- that indicates the first day of the week - 1 = Monday, 2 = Tuesday ... 7 = Sunday (default US English).
--
SET DATEFIRST 1;
SELECT @@DATEFIRST AS first_day_of_the_week;
GO

--
-- @@LANGID returns the local language id of the current language and @@LANGUAGE returns the name.
-- The sp_helplanguage procedure returns information about all langauges or a specific language (
-- remove the English and the function will return all languages).
--
SELECT @@LANGID AS language_id, @@LANGUAGE AS language_name;
GO

sp_helplanguage English;
GO

--
-- @@SPID returns the session ID of the current user process (note this is also listed in
-- the SSMS Properties window in the Connection Details section).
--
SELECT @@SPID AS session_id, SYSTEM_USER AS login_name, USER AS user_name;
GO

--
-- @@VERSION returns the system and build information for the current installation of SQL Server
--
SELECT @@VERSION AS ss_version;
GO

--
--
--
SET CONCAT_NULL_YIELDS_NULL OFF; 
SELECT @@OPTIONS;



