
CREATE PROCEDURE [stage].[Transform_Bridge_UserAccess]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Bridge_UserAccess]


DROP TABLE IF EXISTS #PickEmail
SELECT DISTINCT
	d.EmployeeName,
	e.Email,
	d.Legacy_EmployeeKey,
	m.Legacy_EmployeeID AS ManagerEmployeeID,
	mm.Email AS LeaderEmail
INTO #PickEmail
FROM (
	SELECT
		Email,
		EmployeeID,
		ManagerEmployeeID,
		ROW_NUMBER() OVER (PARTITION BY Email ORDER BY SRC_DW_Valid_FROM DESC) RN
	FROM sourceCubusMasterData.DimEmployee
) e
LEFT JOIN [dim].[Legacy_Employee] d
	ON CONVERT( NVARCHAR(50), d.Legacy_EmployeeKey ) = e.EmployeeID
		AND d.Legacy_EmployeeIsCurrent = 1
LEFT JOIN [dim].[Legacy_Employee] m
	ON CONVERT( NVARCHAR(50), m.Legacy_EmployeeKey ) = e.ManagerEmployeeID
		AND m.Legacy_EmployeeIsCurrent = 1
LEFT JOIN (
	SELECT
		Email,
		EmployeeID,
		ROW_NUMBER() OVER (PARTITION BY Email ORDER BY SRC_DW_Valid_FROM DESC) RN
	FROM sourceCubusMasterData.DimEmployee
) mm
	ON mm.EmployeeID = e.ManagerEmployeeID
		AND mm.RN = 1

WHERE
	1 = 1
	AND e.RN = 1
	AND e.Email IN
	(
		SELECT
			COALESCE( [eventLog.source.userId], [eventLog.source.error.userId] )
		FROM [sourceNuuDataChipperView].[ChipperTicketsEventLog_History]
	)
	AND d.EmployeeName IS NOT NULL

DROP TABLE IF EXISTS #UserAccess

SELECT
	Legacy_EmployeeKey,
	0 AS TopManager,
	EmployeeName,
	Email AS Username
INTO #UserAccess
FROM #PickEmail

UNION ALL

SELECT
	Legacy_EmployeeKey,
	0 AS TopManager,
	EmployeeName,
	LeaderEmail AS Username
FROM #PickEmail

INSERT INTO stage.[Bridge_UserAccess] WITH (TABLOCK) ( Legacy_EmployeeKey, TopManager, EmployeeName, UserName )
SELECT
	Legacy_EmployeeKey,
	TopManager,
	EmployeeName,
	UserName
FROM #UserAccess
ORDER BY
	EmployeeName ASC