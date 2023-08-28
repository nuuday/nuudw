

CREATE view [dba].[ShowDatabasePermissions]
AS

WITH cte AS
	(

		SELECT DISTINCT
			------------------ Show Database level permisions, created by sorav@nuuday.dk 03-08-2021--------------
			pr.name AS [UserName],
			pr.type_desc AS [UserType],
			pe.state_desc AS [PermissionType],
			pe.permission_name AS [Permission]
		FROM sys.database_principals AS pr
	JOIN sys.database_permissions AS pe
		ON pe.grantee_principal_id = pr.principal_id
	)
SELECT
	[UserName],
	[UserType],
	[PermissionType],
	[permission],
	'GRANT ' + [permission] + ' TO [' + [UserName] + ']' COLLATE Latin1_General_CI_AS AS [TSQLStatement]
FROM cte
WHERE
	[permission] IN (
	'CREATE TABLE',
	'CREATE VIEW',
	'CREATE PROCEDURE',
	'CREATE FUNCTION',
	'Execute',
	'SHOWPLAN',
	'VIEW DATABASE STATE',
	'ADMINISTER DATABASE BULK OPERATIONS')