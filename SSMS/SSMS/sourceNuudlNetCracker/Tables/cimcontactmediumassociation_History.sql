CREATE TABLE [sourceNuudlNetCracker].[cimcontactmediumassociation_History] (
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
    [DWIsCurrent]              BIT            NULL,
    [DWValidFromDate]          DATETIME2 (7)  NOT NULL,
    [DWValidToDate]            DATETIME2 (7)  NULL,
    [DWCreatedDate]            DATETIME2 (7)  NULL,
    [DWModifiedDate]           DATETIME2 (7)  NULL,
    [DWIsDeletedInSource]      BIT            NULL,
    [DWDeletedInSourceDate]    DATETIME2 (7)  NULL,
    CONSTRAINT [PK_cimcontactmediumassociation_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimcontactmediumassociation_History]
    ON [sourceNuudlNetCracker].[cimcontactmediumassociation_History];

