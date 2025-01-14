CREATE TABLE [sourceNuudlDawn].[cimindividualname] (
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
    [DWCreatedDate]                   DATETIME2 (7)   DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_cimindividualname] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimindividualname]
    ON [sourceNuudlDawn].[cimindividualname];

