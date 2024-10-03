
CREATE PROCEDURE [stage].[Transform_Dim_Ticket]
	@JobIsIncremental BIT			
AS 

DROP TABLE IF EXISTS #gross_list
SELECT 
	id AS TicketKey
	, ISNULL( NULLIF( ticket_category, '' ) , '?') AS TicketCategory
	, ISNULL( NULLIF( ticket_type, '' ) , '?') AS TicketType
	, ISNULL( NULLIF( [status], '' ) , '?') AS TicketStatus
INTO #gross_list
FROM [sourceNuudlDawnView].[cpmnrmltroubleticket_History]
WHERE NUUDL_IsLatest =1


-------------------------------------------------------------------------------
-- Identify errors 
-------------------------------------------------------------------------------
/*
DROP TABLE IF EXISTS #error_list
CREATE TABLE #error_list (
	error_id nvarchar(36),
	ErrorMessage nvarchar(100)
)

INSERT INTO #error_list (error_id, ErrorMessage)
SELECT TicketKey, 'Duplicate IDs'
FROM #gross_list
GROUP BY TicketKey
HAVING COUNT(*) > 1


-- Saving the latest result in an error table
TRUNCATE TABLE [sourceNuudlNetCracker].[cpmnrmltroubleticket_History_Error] 
INSERT INTO [sourceNuudlNetCracker].[cpmnrmltroubleticket_History_Error] (ErrorMessage, [approval_reason], [closed_by_date], [closed_by_user_id], [closed_by_user_name], [created_by_date], [created_by_user_id], [created_by_user_name], [description], [first_resolution_date], [is_solution_visible_for_contact], [last_approved_by_date], [last_approved_by_user_id], [last_approved_by_user_name], [last_updated_by_date], [last_updated_by_user_id], [last_updated_by_user_name], [problem_start_date], [resolution_reason], [resolved_by_date], [resolved_by_user_id], [resolved_by_user_name], [solution], [ticket_category], [version], [channel_id], [expected_resolution_date], [external_id], [priority], [requested_resolution_date], [severity], [status], [status_change_date], [status_change_reason], [ticket_type], [id], [name], [group_assignee_id], [group_assignee_name], [user_assignee_id], [user_assignee_name], [reporter_id], [reporter_name], [project_id], [project_name], [group_assignee_type], [reporter_type], [user_assignee_type], [closure_code], [is_deleted], [last_modified_ts], [extended_attributes_json_DPT_RETRY], [extended_attributes_json__corrupt_record], [extended_attributes_json_accountNumber], [extended_attributes_json_billId], [extended_attributes_json_changeDate], [extended_attributes_json_change_id], [extended_attributes_json_commitmentFee], [extended_attributes_json_cpmChannel], [extended_attributes_json_deviceModel], [extended_attributes_json_distributionChannel], [extended_attributes_json_earlyTerminationFee], [extended_attributes_json_ichOrderId], [extended_attributes_json_imei], [extended_attributes_json_internationalPhoneNumber], [extended_attributes_json_lastExecutedStep], [extended_attributes_json_legacyReturnOption], [extended_attributes_json_noInWarehouse], [extended_attributes_json_parentTicketCategory], [extended_attributes_json_portedTo], [extended_attributes_json_purchaseDate], [extended_attributes_json_reason], [extended_attributes_json_receiptNumber], [extended_attributes_json_refundAmount], [extended_attributes_json_refundOption], [extended_attributes_json_registrationNumber], [extended_attributes_json_returnBy], [extended_attributes_json_returnMethod], [extended_attributes_json_rphRefundLink], [extended_attributes_json_serialNumber], [extended_attributes_json_storeId], [extended_attributes_json_trackingNumber], [tags_json__corrupt_record], [total_disputed_amount_json__corrupt_record], [total_disputed_amount_json_amount], [total_disputed_amount_json_currencyCode], [total_disputed_amount_json_exponent], [total_initial_amount_json__corrupt_record], [total_initial_amount_json_amount], [total_initial_amount_json_currencyCode], [total_initial_amount_json_exponent], [extended_attributes_json_refundParameters_json_POSPaymentBreakdown], [extended_attributes_json_refundParameters_json_billingAccountId], [extended_attributes_json_refundParameters_json_paymentId], [extended_attributes_json_refundParameters_json_paymentProvider], [extended_attributes_json_refundParameters_json_refundId], [extended_attributes_json_refundParameters_json_refundPaymentId], [extended_attributes_json_rentedEquipmentToReturn_json_id], [extended_attributes_json_rentedEquipmentToReturn_json_name], [extended_attributes_json_rentedEquipmentToReturn_json_returnOption], [NUUDL_ValidFrom], [NUUDL_ValidTo], [NUUDL_IsCurrent], [NUUDL_ID], [NUUDL_StandardizedProcessedTimestamp], [NUUDL_CuratedBatchID], [NUUDL_CuratedProcessedTimestamp], [NUUDL_CuratedSourceFilename], [DWIsCurrent], [DWValidFromDate], [DWValidToDate], [DWCreatedDate], [DWModifiedDate], [DWIsDeletedInSource], [DWDeletedInSourceDate])
SELECT el.ErrorMessage, [approval_reason], [closed_by_date], [closed_by_user_id], [closed_by_user_name], [created_by_date], [created_by_user_id], [created_by_user_name], [description], [first_resolution_date], [is_solution_visible_for_contact], [last_approved_by_date], [last_approved_by_user_id], [last_approved_by_user_name], [last_updated_by_date], [last_updated_by_user_id], [last_updated_by_user_name], [problem_start_date], [resolution_reason], [resolved_by_date], [resolved_by_user_id], [resolved_by_user_name], [solution], [ticket_category], [version], [channel_id], [expected_resolution_date], [external_id], [priority], [requested_resolution_date], [severity], [status], [status_change_date], [status_change_reason], [ticket_type], [id], [name], [group_assignee_id], [group_assignee_name], [user_assignee_id], [user_assignee_name], [reporter_id], [reporter_name], [project_id], [project_name], [group_assignee_type], [reporter_type], [user_assignee_type], [closure_code], [is_deleted], [last_modified_ts], [extended_attributes_json_DPT_RETRY], [extended_attributes_json__corrupt_record], [extended_attributes_json_accountNumber], [extended_attributes_json_billId], [extended_attributes_json_changeDate], [extended_attributes_json_change_id], [extended_attributes_json_commitmentFee], [extended_attributes_json_cpmChannel], [extended_attributes_json_deviceModel], [extended_attributes_json_distributionChannel], [extended_attributes_json_earlyTerminationFee], [extended_attributes_json_ichOrderId], [extended_attributes_json_imei], [extended_attributes_json_internationalPhoneNumber], [extended_attributes_json_lastExecutedStep], [extended_attributes_json_legacyReturnOption], [extended_attributes_json_noInWarehouse], [extended_attributes_json_parentTicketCategory], [extended_attributes_json_portedTo], [extended_attributes_json_purchaseDate], [extended_attributes_json_reason], [extended_attributes_json_receiptNumber], [extended_attributes_json_refundAmount], [extended_attributes_json_refundOption], [extended_attributes_json_registrationNumber], [extended_attributes_json_returnBy], [extended_attributes_json_returnMethod], [extended_attributes_json_rphRefundLink], [extended_attributes_json_serialNumber], [extended_attributes_json_storeId], [extended_attributes_json_trackingNumber], [tags_json__corrupt_record], [total_disputed_amount_json__corrupt_record], [total_disputed_amount_json_amount], [total_disputed_amount_json_currencyCode], [total_disputed_amount_json_exponent], [total_initial_amount_json__corrupt_record], [total_initial_amount_json_amount], [total_initial_amount_json_currencyCode], [total_initial_amount_json_exponent], [extended_attributes_json_refundParameters_json_POSPaymentBreakdown], [extended_attributes_json_refundParameters_json_billingAccountId], [extended_attributes_json_refundParameters_json_paymentId], [extended_attributes_json_refundParameters_json_paymentProvider], [extended_attributes_json_refundParameters_json_refundId], [extended_attributes_json_refundParameters_json_refundPaymentId], [extended_attributes_json_rentedEquipmentToReturn_json_id], [extended_attributes_json_rentedEquipmentToReturn_json_name], [extended_attributes_json_rentedEquipmentToReturn_json_returnOption], [NUUDL_ValidFrom], [NUUDL_ValidTo], [NUUDL_IsCurrent], [NUUDL_ID], [NUUDL_StandardizedProcessedTimestamp], [NUUDL_CuratedBatchID], [NUUDL_CuratedProcessedTimestamp], [NUUDL_CuratedSourceFilename], [DWIsCurrent], [DWValidFromDate], [DWValidToDate], [DWCreatedDate], [DWModifiedDate], [DWIsDeletedInSource], [DWDeletedInSourceDate]
FROM [sourceNuudlNetCracker].[cpmnrmltroubleticket_History] a
INNER JOIN #error_list el ON el.error_id = a.id

*/
-------------------------------------------------------------------------------
-- Update stage table 
-------------------------------------------------------------------------------

TRUNCATE TABLE [stage].[Dim_Ticket]

INSERT INTO stage.[Dim_Ticket] WITH (TABLOCK) (TicketKey, TicketCategory, TicketType, TicketStatus)
SELECT 
	TicketKey
	, TicketCategory
	, TicketType
	, TicketStatus
FROM #gross_list
--WHERE TicketKey NOT IN (SELECT error_id FROM #error_list)