CREATE TABLE [sourceNuudlNetCracker].[cimcontactmediumassociation] (
    [id]                       NVARCHAR (36)  NULL,
    [ref_id]                   NVARCHAR (36)  NULL,
    [ref_type]                 NVARCHAR (300) NULL,
    [contact_medium_id]        NVARCHAR (36)  NULL,
    [changed_by_json_userId]   NVARCHAR (36)  NULL,
    [active_from]              DATETIME2 (7)  NULL,
    [is_deleted]               BIT            NULL,
    [last_modified_ts]         DATETIME2 (7)  NULL,
    [active_to]                NVARCHAR (300) NULL,
    [version]                  INT            NULL,
    [is_current]               BIT            NULL,
    [changed_by_json_userName] NVARCHAR (300) NULL,
    [NUUDL_ValidFrom]          DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]            DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]          BIT            NULL,
    [NUUDL_ID]                 BIGINT         NOT NULL,
    [NUUDL_CuratedBatchID]     BIGINT         NULL,
    [DWCreatedDate]            DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_cimcontactmediumassociation] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimcontactmediumassociation]
    ON [sourceNuudlNetCracker].[cimcontactmediumassociation];

