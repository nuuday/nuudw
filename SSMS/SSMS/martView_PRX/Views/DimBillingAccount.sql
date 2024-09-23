
CREATE VIEW [martView_PRX].[DimBillingAccount]
AS
SELECT 
	[BillingAccountID],
	[BillingAccountKey],
	DWValidFromDate,
	DWValidToDate,
	DWIsCurrent,
	DWIsDeleted
FROM [dimView].[BillingAccount]