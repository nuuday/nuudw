
CREATE VIEW [cubeView_PRX].[DimTransactionState]
AS
SELECT 	[TransactionStateID],	[TransactionStateKey],	[TransactionStateName]
FROM [dimView].[TransactionState]