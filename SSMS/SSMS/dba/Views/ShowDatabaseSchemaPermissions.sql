CREATE view [dba].[ShowDatabaseSchemaPermissions]
AS
SELECT
	------------------ Show Database Schema Permissions, created by sorav@nuuday.dk 03-08-2021--------------
	permission_name AS Permission,
	ss.name AS [Schema],
	sdpr.name AS [UserName],
	state_desc AS PermissionType,
	state_desc + ' ' + permission_name + ' on Schema::[' + ss.name + '] to [' + sdpr.name + ']' COLLATE Latin1_General_CI_AS AS [TSQLStatement]
FROM sys.DATABASE_PERMISSIONS AS sdp
JOIN sys.SCHEMAS AS ss
	ON sdp.major_id = ss.schema_id
		AND sdp.class_desc = 'Schema'
JOIN sys.database_principals AS sdpr
	ON sdp.grantee_principal_id = sdpr.principal_id