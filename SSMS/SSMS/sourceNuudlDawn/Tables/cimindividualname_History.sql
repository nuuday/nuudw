CREATE TABLE [sourceNuudlDawn].[cimindividualname_History] (
    [active_from]                     DATETIME2 (7)   NULL,
    [aristocratic_title]              NVARCHAR (4000) NULL,
    [changed_by]                      NVARCHAR (MAX)  NULL,
    [family_generation]               NVARCHAR (4000) NULL,
    [family_name]                     NVARCHAR (4000) NULL,
    [family_name_prefix]              NVARCHAR (4000) NULL,
    [form_of_address]                 NVARCHAR (4000) NULL,
    [formatted_name]                  NVARCHAR (4000) NULL,
    [generation]                      NVARCHAR (4000) NULL,
    [given_name]                      NVARCHAR (4000) NULL,
    [id]                              NVARCHAR (50)   NULL,
    [individual_id]                   NVARCHAR (50)   NULL,
    [legal_name]                      NVARCHAR (4000) NULL,
    [middle_name]                     NVARCHAR (4000) NULL,
    [preferred_given_name]            NVARCHAR (4000) NULL,
    [qualifications]                  NVARCHAR (4000) NULL,
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
    [DWIsCurrent]                     BIT             NULL,
    [DWValidFromDate]                 DATETIME2 (7)   NOT NULL,
    [DWValidToDate]                   DATETIME2 (7)   NULL,
    [DWCreatedDate]                   DATETIME2 (7)   NULL,
    [DWModifiedDate]                  DATETIME2 (7)   NULL,
    [DWIsDeletedInSource]             BIT             NULL,
    [DWDeletedInSourceDate]           DATETIME2 (7)   NULL,
    CONSTRAINT [PK_cimindividualname_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimindividualname_History]
    ON [sourceNuudlDawn].[cimindividualname_History];

