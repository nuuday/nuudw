CREATE VIEW cubeView_FAM.[Dim Sales Channel]
AS
SELECT
	[FAM_SalesChannelID] AS [SalesChannelID],
	[FAM Sales Channel Key] AS [Sales Channel Key],
	[Sales Channel Name]
FROM [dimView].[FAM Sales Channel]