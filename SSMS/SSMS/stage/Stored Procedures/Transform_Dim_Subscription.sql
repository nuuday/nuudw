
CREATE PROCEDURE [stage].[Transform_Dim_Subscription]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_Subscription]

INSERT INTO [stage].[Dim_Subscription] WITH (TABLOCK) (SubscriptionKey)

--SELECT CONVERT( NVARCHAR(36),id ) AS Subscriptionkey from [sourceNuudlNetCrackerView].[ibsnrmlproductinstance_History]
--UNION
SELECT DISTINCT CONVERT( NVARCHAR(36),id ) AS SubscriptionKey from [sourceNuudlNetCrackerView].[ibsitemshistory_History]