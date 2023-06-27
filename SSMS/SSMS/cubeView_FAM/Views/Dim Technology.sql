
CREATE VIEW cubeView_FAM.[Dim Technology]
AS
SELECT
	[FAM_TechnologyID] AS [TechnologyID],
	[FAM Technology Key] AS [Technology Key],
	[Technology Name]
FROM [dimView].[FAM Technology]