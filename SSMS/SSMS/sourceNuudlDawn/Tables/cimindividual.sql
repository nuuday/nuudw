CREATE TABLE [sourceNuudlDawn].[cimindividual] (
    [active_from]                     DATETIME2 (7)   NULL,
    [billing_data]                    NVARCHAR (MAX)  NULL,
    [birthdate]                       NVARCHAR (4000) NULL,
    [changed_by]                      NVARCHAR (MAX)  NULL,
    [country_of_birth]                NVARCHAR (4000) NULL,
    [death_date]                      NVARCHAR (4000) NULL,
    [extended_attributes]             NVARCHAR (MAX)  NULL,
    [gender]                          NVARCHAR (4000) NULL,
    [id]                              NVARCHAR (50)   NULL,
    [idempotency_key]                 NVARCHAR (4000) NULL,
    [location]                        NVARCHAR (4000) NULL,
    [marital_status]                  NVARCHAR (4000) NULL,
    [nationality]                     NVARCHAR (4000) NULL,
    [place_of_birth]                  NVARCHAR (4000) NULL,
    [status]                          NVARCHAR (4000) NULL,
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
    CONSTRAINT [PK_cimindividual] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);






GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimindividual]
    ON [sourceNuudlDawn].[cimindividual];





