CREATE VIEW [dba].[ShowDatabaseRoles] 
AS
SELECT
	------------------ Show Database Roles members, created by sorav@nuuday.dk 03-08-2021--------------
	DP1.name AS RoleName,
	ISNULL( DP2.name, 'No members' ) AS UserName,
	DP1.is_fixed_role AS SystemRole,
	CASE
		WHEN DP2.name IS NOT NULL AND DP2.name <> 'dbo' THEN 'EXEC sp_droprolemember ' + '''' + DP1.name + '''' + ' , ' + '''' + DP2.name + ''''
	END AS [TSQLStatementRemoveUserFromRole],
	CASE
		WHEN DP2.name IS NOT NULL AND DP2.name <> 'dbo' THEN 'EXEC sp_addrolemember ' + '''' + DP1.name + '''' + ' , ' + '''' + DP2.name + ''''
	END AS [TSQLStatementAddUserToRole],
	CASE
		WHEN DP1.is_fixed_role = 0 AND DP1.name <> 'public' THEN 'EXEC sp_addrole ' + '''' + DP1.name + ''''
	END AS [TSQLStatementAddRole],
	CASE
		WHEN DP1.is_fixed_role = 0 AND DP1.name <> 'public' THEN 'EXEC sp_droprole ' + '''' + DP1.name + ''''
	END AS [TSQLStatementRemoveRole]
FROM sys.database_role_members AS DRM
RIGHT OUTER JOIN sys.database_principals AS DP1
	ON DRM.role_principal_id = DP1.principal_id
LEFT OUTER JOIN sys.database_principals AS DP2
	ON DRM.member_principal_id = DP2.principal_id
--------------------------------------------------

-----------------------------------------------------
WHERE
	DP1.type = 'R';