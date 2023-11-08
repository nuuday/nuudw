CREATE TABLE [sourceNuudlNetCracker].[cimpartyrole] (
    [id]                             NVARCHAR (36)  NULL,
    [active_from]                    DATETIME2 (7)  NULL,
    [name]                           NVARCHAR (300) NULL,
    [party_role_type]                NVARCHAR (300) NULL,
    [status]                         NVARCHAR (300) NULL,
    [status_reason]                  NVARCHAR (300) NULL,
    [engaged_party_name]             NVARCHAR (300) NULL,
    [engaged_party_description]      NVARCHAR (300) NULL,
    [engaged_party_id]               NVARCHAR (36)  NULL,
    [engaged_party_ref_type]         NVARCHAR (300) NULL,
    [extended_attributes]            NVARCHAR (300) NULL,
    [changed_by_json_userId]         NVARCHAR (36)  NULL,
    [start_date_time]                DATETIME2 (7)  NULL,
    [end_date_time]                  NVARCHAR (300) NULL,
    [billing_synchronization_status] NVARCHAR (300) NULL,
    [idempotency_key]                NVARCHAR (300) NULL,
    [ola_ref]                        NVARCHAR (300) NULL,
    [is_deleted]                     BIT            NULL,
    [last_modified_ts]               DATETIME2 (7)  NULL,
    [active_to]                      DATETIME2 (7)  NULL,
    [version]                        INT            NULL,
    [is_current]                     BIT            NULL,
    [changed_by_json_userName]       NVARCHAR (300) NULL,
    [NUUDL_ValidFrom]                DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                  DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]                BIT            NULL,
    [NUUDL_ID]                       BIGINT         NOT NULL,
    [NUUDL_CuratedBatchID]           BIGINT         NULL,
    [DWCreatedDate]                  DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_cimpartyrole] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimpartyrole]
    ON [sourceNuudlNetCracker].[cimpartyrole];

