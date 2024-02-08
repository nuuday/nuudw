
CREATE PROCEDURE [stage].[Transform_Dim_BillingAccount]
	@JobIsIncremental BIT			
AS 

TRUNCATE TABLE [stage].[Dim_BillingAccount]

INSERT INTO [stage].[Dim_BillingAccount] WITH (TABLOCK) (BillingAccountKey,DWCreatedDate)

select distinct CONVERT( NVARCHAR(10),account_num ) AS BillingAccountKey,
GETDATE() AS DWCreatedDate
from [sourceNuudlNetCrackerView].[nrmaccountkeyname_History] accountk
INNER JOIN 
(

select distinct item_json_accountRef_json_refId account_ref_id from [sourceNuudlNetCrackerView].[ibsitemshistory_History]
) a on a.account_ref_id=accountk.name