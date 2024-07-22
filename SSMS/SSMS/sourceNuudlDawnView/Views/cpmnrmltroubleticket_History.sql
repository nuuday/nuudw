

CREATE VIEW [sourceNuudlDawnView].[cpmnrmltroubleticket_History]
AS
SELECT 
	[approval_reason] ,
	[channel_id] ,
	[closed_by_date] ,
	[closed_by_user_id] ,
	[closed_by_user_name] ,
	[closure_code] ,
	[created_by_date] ,
	CAST([created_by_date] AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' as datetime) [created_by_date_CET],
	[created_by_user_id] ,
	[created_by_user_name] ,
	[description] ,
	[dispute_item] ,
	[expected_resolution_date] ,
	[extended_attributes] ,
	CAST(
		CASE JSON_VALUE(extended_attributes, '$.changeDate') WHEN 'Invalid date' THEN null ELSE JSON_VALUE(extended_attributes, '$.changeDate') END 
		AS datetime
	) AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' AS [extended_attributes_changeDate_CET] ,
	[external_id] ,
	[first_resolution_date] ,
	[group_assignee_id] ,
	[group_assignee_name] ,
	[group_assignee_type] ,
	[id] ,
	[is_solution_visible_for_contact] ,
	[last_approved_by_date] ,
	[last_approved_by_user_id] ,
	[last_approved_by_user_name] ,
	[last_updated_by_date] ,
	[last_updated_by_user_id] ,
	[last_updated_by_user_name] ,
	[name] ,
	[op] ,
	[priority] ,
	[problem_start_date] ,
	[project_id] ,
	[project_name] ,
	[reporter_id] ,
	[reporter_name] ,
	[reporter_type] ,
	[requested_resolution_date] ,
	[resolution_reason] ,
	[resolved_by_date] ,
	[resolved_by_user_id] ,
	[resolved_by_user_name] ,
	[severity] ,
	[solution] ,
	[status] ,
	[status_change_date] ,
	CAST([status_change_date] AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' as datetime) [status_change_date_CET],
	[status_change_reason] ,
	[tags] ,
	[ticket_category] ,
	[ticket_type] ,
	[total_disputed_amount] ,
	[total_initial_amount] ,
	[ts_ms] ,
	[user_assignee_id] ,
	[user_assignee_name] ,
	[user_assignee_type] ,
	[version] ,
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
FROM [sourceNuudlDawn].[cpmnrmltroubleticket_History]
WHERE DWIsCurrent = 1