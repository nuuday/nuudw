CREATE VIEW [dimView].[Dummy] 
AS
SELECT
	[DummyID]
	,[DummyKey] AS [DummyKey]
	,[SomeAttribute] AS [SomeAttribute]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[Dummy]