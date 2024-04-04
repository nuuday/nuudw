

CREATE VIEW [sourceNuudlNetCrackerView].[nrmcustproductdetails_History]
AS
SELECT 
	[customer_ref] ,
	[product_seq] ,
	[start_dat] ,
	[end_dat] ,
	CAST([start_dat] AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' as datetime) [start_dat_CET],
	CAST([end_dat] AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' as datetime) [end_dat_CET],
	[account_num] ,
	[budget_centre_seq] ,
	[product_label] ,
	[cust_product_contact_seq] ,
	[contract_seq] ,
	[cps_id] ,
	[tax_exempt_ref] ,
	[tax_exempt_txt] ,
	[default_event_source] ,
	[domain_id] ,
	[budget_payment_plan_id] ,
	[community_group_id] ,
	[community_group_owner_boo] ,
	[override_product_name] ,
	[tax_inclusive_boo] ,
	[is_current] ,
	[NUUDL_ValidFrom] ,
	[NUUDL_ValidTo] ,
	[NUUDL_IsCurrent] ,
	[NUUDL_ID] ,
	[NUUDL_CuratedBatchID] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuudlNetCracker].[nrmcustproductdetails_History]
WHERE DWIsCurrent = 1