
CREATE PROCEDURE [stage].[Transform_Dim_BillingAccount]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_BillingAccount]

INSERT INTO [stage].[Dim_BillingAccount] WITH (TABLOCK) (BillingAccountKey)
SELECT DISTINCT
	CONVERT( NVARCHAR(10), account_num ) AS BillingAccountKey
FROM [sourceNuudlDawnView].[nrmaccountkeyname_History] accountk
WHERE 
	accountk.NUUDL_IsCurrent = 1
	AND accountk.name IN (
			SELECT JSON_VALUE(item_accountRef,'$[0].refId') refId
			FROM [sourceNuudlDawnView].[ibsitemshistory_History]
		)