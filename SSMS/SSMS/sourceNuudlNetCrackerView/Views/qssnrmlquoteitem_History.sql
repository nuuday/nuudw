﻿
CREATE VIEW [sourceNuudlNetCrackerView].[qssnrmlquoteitem_History]
AS
SELECT 
	[account_id] ,
	[action] ,
	[active_from] ,
	[active_to] ,
	[amount] ,
	[approval_level] ,
	[availability_check_result] ,
	[business_action] ,
	[business_group_id] ,
	[business_group_name] ,
	[contracted_date] ,
	[creation_time] ,
	[disconnection_reason] ,
	[distribution_channel_id] ,
	[extended_parameters_json_0000372d_163b_48c9_83a9_17d7a237a2c0] ,
	[extended_parameters_json_150338a0_0cf7_4428_b3fc_dbca99bd9343] ,
	[extended_parameters_json_2262debf_d95a_4e8b_957a_a3908b7c5df9] ,
	[extended_parameters_json_2ee0ab36_03de_4020_a9c8_0793209a7ac7] ,
	[extended_parameters_json_465526c0_80c5_4a06_89ed_3a3bd6957c83] ,
	[extended_parameters_json_4a15af47_9eb0_4546_8c9c_bc75387fe74c] ,
	[extended_parameters_json_55ab2bdf_151f_4c38_937f_7b5d337e6756] ,
	[extended_parameters_json_6409d551_fcfe_4dc2_a552_776e73bb3f69] ,
	[extended_parameters_json_7c4b0eb2_5c5a_40da_8e12_0a0718273e3b] ,
	[extended_parameters_json_activationDateOnWorkingDay] ,
	[extended_parameters_json_af199492_152e_459c_a32b_eef81eef0a71] ,
	[extended_parameters_json_agreementId] ,
	[extended_parameters_json_availabilityDate] ,
	[extended_parameters_json_d22ac111_fb6a_42ba_b1b3_23b32b923d73] ,
	[extended_parameters_json_deactivationFee] ,
	[extended_parameters_json_deviceReturnOperation] ,
	[extended_parameters_json_df9bf9ab_7965_4cf2_8c5d_32d8c2e97e93] ,
	[extended_parameters_json_e012d094_2cbf_46cc_82e5_a915f9751e09] ,
	[extended_parameters_json_extPaymentId] ,
	[extended_parameters_json_f025e2e4_041c_43e9_875b_21309590e15c] ,
	[extended_parameters_json_feePerDay] ,
	[extended_parameters_json_ff18f216_93ee_486d_86eb_b0d8396ce420] ,
	[extended_parameters_json_isInsuranceAdded] ,
	[extended_parameters_json_isPoaSigned] ,
	[extended_parameters_json_noInWarehouse] ,
	[extended_parameters_json_offeringBusinessUse] ,
	[extended_parameters_json_paymentProvider] ,
	[extended_parameters_json_portalActivationDateIsNotProvided] ,
	[extended_parameters_json_portalEndOfTheNoticePeriodOptionSelected] ,
	[extended_parameters_json_portalRefuseUsageSpendLimit] ,
	[extended_parameters_json_portInTermsAccepted] ,
	[extended_parameters_json_preOrder] ,
	[extended_parameters_json_returnMethod] ,
	[extended_parameters_json_softReservationState] ,
	[extended_parameters_json_undefined] ,
	[extended_parameters_json_userEmail] ,
	[extended_parameters_json_userName] ,
	[extended_parameters_json_userPhone] ,
	[geo_site_id] ,
	[id] ,
	[market_id] ,
	[marketing_bundle_id] ,
	[number_of_installments] ,
	[parent_quote_item_id] ,
	[planned_disconnection_date] ,
	[product_instance_id] ,
	[product_offering_id] ,
	[product_specification_id] ,
	[product_specification_version] ,
	[quantity] ,
	[quote_id] ,
	[root_quote_item_id] ,
	[state] ,
	[quote_version] ,
	[is_deleted] ,
	[last_modified_ts] ,
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
FROM [sourceNuudlNetCracker].[qssnrmlquoteitem_History]
WHERE DWIsCurrent = 1