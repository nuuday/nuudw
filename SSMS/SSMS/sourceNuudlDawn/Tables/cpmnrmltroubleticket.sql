CREATE TABLE [sourceNuudlDawn].[cpmnrmltroubleticket] (
    [approval_reason]                 NVARCHAR (4000) NULL,
    [channel_id]                      NVARCHAR (50)   NULL,
    [closed_by_date]                  DATETIME2 (7)   NULL,
    [closed_by_user_id]               NVARCHAR (50)   NULL,
    [closed_by_user_name]             NVARCHAR (4000) NULL,
    [closure_code]                    NVARCHAR (4000) NULL,
    [created_by_date]                 DATETIME2 (7)   NULL,
    [created_by_user_id]              NVARCHAR (50)   NULL,
    [created_by_user_name]            NVARCHAR (4000) NULL,
    [description]                     NVARCHAR (MAX)  NULL,
    [dispute_item]                    NVARCHAR (MAX)  NULL,
    [expected_resolution_date]        NVARCHAR (4000) NULL,
    [extended_attributes]             NVARCHAR (MAX)  NULL,
    [external_id]                     NVARCHAR (50)   NULL,
    [first_resolution_date]           NVARCHAR (4000) NULL,
    [group_assignee_id]               NVARCHAR (50)   NULL,
    [group_assignee_name]             NVARCHAR (4000) NULL,
    [group_assignee_type]             NVARCHAR (4000) NULL,
    [id]                              NVARCHAR (50)   NULL,
    [is_solution_visible_for_contact] NVARCHAR (4000) NULL,
    [last_approved_by_date]           NVARCHAR (4000) NULL,
    [last_approved_by_user_id]        NVARCHAR (50)   NULL,
    [last_approved_by_user_name]      NVARCHAR (4000) NULL,
    [last_updated_by_date]            DATETIME2 (7)   NULL,
    [last_updated_by_user_id]         NVARCHAR (50)   NULL,
    [last_updated_by_user_name]       NVARCHAR (4000) NULL,
    [name]                            NVARCHAR (4000) NULL,
    [priority]                        NVARCHAR (4000) NULL,
    [problem_start_date]              NVARCHAR (4000) NULL,
    [project_id]                      NVARCHAR (50)   NULL,
    [project_name]                    NVARCHAR (4000) NULL,
    [reporter_id]                     NVARCHAR (50)   NULL,
    [reporter_name]                   NVARCHAR (4000) NULL,
    [reporter_type]                   NVARCHAR (4000) NULL,
    [requested_resolution_date]       NVARCHAR (4000) NULL,
    [resolution_reason]               NVARCHAR (4000) NULL,
    [resolved_by_date]                NVARCHAR (4000) NULL,
    [resolved_by_user_id]             NVARCHAR (50)   NULL,
    [resolved_by_user_name]           NVARCHAR (4000) NULL,
    [severity]                        NVARCHAR (4000) NULL,
    [solution]                        NVARCHAR (4000) NULL,
    [status]                          NVARCHAR (4000) NULL,
    [status_change_date]              DATETIME2 (7)   NULL,
    [status_change_reason]            NVARCHAR (4000) NULL,
    [tags]                            NVARCHAR (MAX)  NULL,
    [ticket_category]                 NVARCHAR (4000) NULL,
    [ticket_type]                     NVARCHAR (4000) NULL,
    [total_disputed_amount]           NVARCHAR (4000) NULL,
    [total_initial_amount]            NVARCHAR (4000) NULL,
    [user_assignee_id]                NVARCHAR (50)   NULL,
    [user_assignee_name]              NVARCHAR (4000) NULL,
    [user_assignee_type]              NVARCHAR (4000) NULL,
    [version]                         NVARCHAR (4000) NULL,
    [ts_ms]                           BIGINT          NULL,
    [lsn]                             BIGINT          NULL,
    [op]                              NVARCHAR (4000) NULL,
    [NUUDL_IsCurrent]                 BIT             NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)   NULL,
    [NUUDL_CuratedBatchID]            INT             NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (4000) NULL,
    [NUUDL_IsDeleted]                 BIT             NULL,
    [NUUDL_DeleteType]                NVARCHAR (4000) NULL,
    [NUUDL_ID]                        BIGINT          NOT NULL,
    [NUUDL_IsLatest]                  BIT             NULL,
    [DWCreatedDate]                   DATETIME2 (7)   DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_cpmnrmltroubleticket] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);






GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cpmnrmltroubleticket]
    ON [sourceNuudlDawn].[cpmnrmltroubleticket];





