CREATE VIEW [dimView].[BillingAccount] 
AS
SELECT
	[BillingAccountID]
	,[BillingAccountKey] AS [BillingAccountKey]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[BillingAccount]