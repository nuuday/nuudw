

CREATE VIEW [cubeView_FAM].[Dim Chipper Status]
AS
SELECT
	[FAM_ChipperStatusID] AS [ChipperStatusID],
	[FAM Chipper Status Key] AS [Chipper Status Key],
	[Chipper Status Name]
FROM [dimView].[FAM Chipper Status]