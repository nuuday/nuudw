﻿
CREATE VIEW [sourceNuudlNetCrackerView].[qssnrmlquote_History]
AS
SELECT 
	[approval_level] ,
	[assign_to] ,
	[brand_id] ,
	[business_action] ,
	[cancellation_reason] ,
	[customer_category_id] ,
	[customer_committed_date] ,
	[customer_id] ,
	[customer_requested_date] ,
	[delivery_method] ,
	[distribution_channel_id] ,
	[expiration_date] ,
	[extended_parameters_json_activityTime] ,
	[extended_parameters_json_agreementId] ,
	[extended_parameters_json_ApplicationGuid] ,
	[extended_parameters_json_authDateTime] ,
	[extended_parameters_json_autoPaymentFlag] ,
	[extended_parameters_json_cardExpiryDate] ,
	[extended_parameters_json_cardNumber] ,
	[extended_parameters_json_cardType] ,
	[extended_parameters_json_contactForAbandoned] ,
	[extended_parameters_json_creditCheckDate] ,
	[extended_parameters_json_creditCheckDetails] ,
	[extended_parameters_json_creditCheckExpirationDate] ,
	[extended_parameters_json_creditCheckRequired] ,
	[extended_parameters_json_creditCheckStatus] ,
	[extended_parameters_json_currentStockId] ,
	[extended_parameters_json_customerAccountNumber] ,
	[extended_parameters_json_customerFirstName] ,
	[extended_parameters_json_disruptionConsent] ,
	[extended_parameters_json_documentLastDigits] ,
	[extended_parameters_json_documentType] ,
	[extended_parameters_json_extPaymentId] ,
	[extended_parameters_json_flow_id] ,
	[extended_parameters_json_flowId] ,
	[extended_parameters_json_formId] ,
	[extended_parameters_json_hardReservationState] ,
	[extended_parameters_json_infoId] ,
	[extended_parameters_json_initialTotalLoanAmount] ,
	[extended_parameters_json_isLoanAvailable] ,
	[extended_parameters_json_loanApplicationGuid] ,
	[extended_parameters_json_loanApplicationId] ,
	[extended_parameters_json_loanRequestNotAvailable] ,
	[extended_parameters_json_loanRequestStatus] ,
	[extended_parameters_json_loanTerm] ,
	[extended_parameters_json_marketId] ,
	[extended_parameters_json_marketingConsent] ,
	[extended_parameters_json_mobilePhoneNumber] ,
	[extended_parameters_json_mpNumber] ,
	[extended_parameters_json_partnerId] ,
	[extended_parameters_json_PAYMENT_STATUS] ,
	[extended_parameters_json_paymentProvider] ,
	[extended_parameters_json_paymentSubscriptionId] ,
	[extended_parameters_json_portalDeliveryIsConfirmed] ,
	[extended_parameters_json_portalExpressBankLoanApproved] ,
	[extended_parameters_json_portalFinancingOptionsConfirmed] ,
	[extended_parameters_json_portalPersonalInformationIsConfirmed] ,
	[extended_parameters_json_portalQuoteReviewConfirmed] ,
	[extended_parameters_json_requestStatus] ,
	[extended_parameters_json_reservationExpirationDate] ,
	[extended_parameters_json_stockAddress] ,
	[extended_parameters_json_stockName] ,
	[external_id] ,
	[id] ,
	[initial_distribution_channel_id] ,
	[name] ,
	[new_msa] ,
	[number] ,
	[opportunity_id] ,
	[override_mode] ,
	[owner] ,
	[price_list_id] ,
	[quote_creation_date] ,
	[revision] ,
	[state] ,
	[updated_when] ,
	[version] ,
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
FROM [sourceNuudlNetCracker].[qssnrmlquote_History]
WHERE DWIsCurrent = 1