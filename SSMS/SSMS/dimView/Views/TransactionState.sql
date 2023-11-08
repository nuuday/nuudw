CREATE VIEW [dimView].[TransactionState] 
AS
SELECT
	[TransactionStateID]
	,[TransactionStateKey] AS [TransactionStateKey]
	,[TransactionStateName] AS [TransactionStateName]
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeleted]
	
FROM [dim].[TransactionState]