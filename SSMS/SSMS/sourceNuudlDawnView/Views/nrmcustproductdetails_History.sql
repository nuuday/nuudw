

CREATE VIEW [sourceNuudlDawnView].[nrmcustproductdetails_History]
AS
SELECT 
	[account_num] ,
	[budget_centre_seq] ,
	[budget_payment_plan_id] ,
	[community_group_id] ,
	[community_group_owner_boo] ,
	[contract_seq] ,
	[cps_id] ,
	[cust_product_contact_seq] ,
	[customer_ref] ,
	[default_event_source] ,
	[domain_id] ,
	[end_dat] ,
	[op] ,
	[override_product_name] ,
	[product_label] ,
	[product_seq] ,
	[start_dat] ,
	[tax_exempt_ref] ,
	[tax_exempt_txt] ,
	[tax_inclusive_boo] ,
	[ts_ms] ,
	CAST([start_dat] AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' as datetime) [start_dat_CET],
	CAST([end_dat] AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' as datetime) [end_dat_CET],
	[NUUDL_CuratedBatchID] ,
	[NUUDL_CuratedProcessedTimestamp] ,
	[NUUDL_IsCurrent] ,
	[NUUDL_ValidFrom] ,
	[NUUDL_ValidTo] ,
	[NUUDL_ID] 
	,[DWIsCurrent]
	,[DWValidFromDate]
	,[DWValidToDate]
	,[DWCreatedDate]
	,[DWModifiedDate]
	,[DWIsDeletedInSource]
	,[DWDeletedInSourceDate]
FROM [sourceNuudlDawn].[nrmcustproductdetails_History]
WHERE DWIsCurrent = 1