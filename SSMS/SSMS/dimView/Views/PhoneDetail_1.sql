CREATE VIEW [dimView].[PhoneDetail] 
AS
SELECT
	[PhoneDetailID]
	,[PhoneDetailkey] AS [PhoneDetailkey]
	,[PhoneStatus] AS [PhoneStatus]
	,[PhoneCategory] AS [PhoneCategory]
	,[PortedIn] AS [PortedIn]
	,[PortedOut] AS [PortedOut]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[PhoneDetail]