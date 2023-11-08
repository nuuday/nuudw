
CREATE PROCEDURE [stage].[Transform_Dim_TransactionState]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_TransactionState]

INSERT INTO [stage].[Dim_TransactionState] WITH (TABLOCK) (TransactionStateKey, TransactionStateName,DWCreatedDate)


SELECT 1 as TransactionStateKey,'ACTIVE' as TransactionStateName , GETDATE() AS DWCreatedDate
union all
SELECT 2 as TransactionStateKey,'DISCONNECTED' as TransactionStateName ,GETDATE() AS DWCreatedDate
union all
SELECT 3 as TransactionStateKey,'COMPLETED' as  TransactionStateName ,GETDATE() AS DWCreatedDate