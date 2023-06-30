CREATE VIEW cubeView_FAM.[Dim Open Incidents Group]
AS
SELECT
	[FAM_OpenIncidentsGroupID] AS [OpenIncidentsGroupID],
	[FAM Open Incidents Group Key] AS [Open Incidents Group Key],
	[Open Incidents Group]
FROM [dimView].[FAM Open Incidents Group]