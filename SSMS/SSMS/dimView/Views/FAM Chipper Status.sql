CREATE VIEW [dimView].[FAM Chipper Status] 
AS
SELECT
	[FAM_ChipperStatusID]
	,[FAM_ChipperStatusKey] AS [FAM Chipper Status Key]
	,[ChipperStatusName] AS [Chipper Status Name]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[FAM_ChipperStatus]