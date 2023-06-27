CREATE VIEW cubeView_FAM.[Dim Infrastructure]
AS
SELECT
	[FAM_InfrastructureID] AS [InfrastructureID],
	[FAM Infrastructure Key] AS [Infrastructure Key],
	[Infrastructure Name]
FROM [dimView].[FAM Infrastructure]