
CREATE VIEW [martView_PRX].[DimTechnology]
AS
SELECT 
	[TechnologyID],
	[TechnologyKey],
	DWValidFromDate,
	DWValidToDate,
	DWIsCurrent,
	DWIsDeleted
FROM [dimView].[Technology]