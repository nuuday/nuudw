

CREATE view [dba].[ShowDatabaseUsers]
AS
------------------ Show Database Users, created by sorav@nuuday.dk 03-08-2021--------------
SELECT
	name AS UserName,
	type_desc AS UserType,
	authentication_type_desc AS AuthenticationType,
	default_schema_name AS DefaultSchemaName,
	create_date AS CreateDate,
	modify_date AS ModifyDate
FROM sys.database_principals
WHERE
	type NOT IN ('R')
	AND sid IS NOT NULL
	AND name NOT IN ('guest', 'dbo')