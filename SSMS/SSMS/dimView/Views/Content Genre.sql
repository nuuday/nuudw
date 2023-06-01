CREATE VIEW [dimView].[Content Genre] 
AS
SELECT
	[ContentGenreID]
	,[ContentGenreKey] AS [Content Genre Key]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[ContentGenre]