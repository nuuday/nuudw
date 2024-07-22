
CREATE PROCEDURE [stage].[Transform_Dim_Subscription]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Subscription]

INSERT INTO [stage].[Dim_Subscription] WITH (TABLOCK) (SubscriptionKey)
SELECT DISTINCT
	CONVERT( NVARCHAR(36), id ) AS SubscriptionKey
FROM [sourceNuudlDawnView].[ibsitemshistory_History]
WHERE NUUDL_IsCurrent = 1