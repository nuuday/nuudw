CREATE TABLE [sourceNuudlDawn].[cimindividual] (
    [active_from]                     DATETIME2 (7)  NULL,
    [billing_data]                    NVARCHAR (MAX) NULL,
    [birthdate]                       DATE           NULL,
    [changed_by]                      NVARCHAR (MAX) NULL,
    [country_of_birth]                NVARCHAR (500) NULL,
    [death_date]                      DATE           NULL,
    [extended_attributes]             NVARCHAR (MAX) NULL,
    [gender]                          NVARCHAR (500) NULL,
    [id]                              NVARCHAR (50)  NULL,
    [idempotency_key]                 NVARCHAR (500) NULL,
    [location]                        NVARCHAR (500) NULL,
    [marital_status]                  NVARCHAR (500) NULL,
    [nationality]                     NVARCHAR (500) NULL,
    [op]                              NVARCHAR (500) NULL,
    [place_of_birth]                  NVARCHAR (500) NULL,
    [status]                          NVARCHAR (500) NULL,
    [ts_ms]                           BIGINT         NULL,
    [NUUDL_CuratedBatchID]            INT            NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (500) NULL,
    [NUUDL_IsCurrent]                 BIT            NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)  NULL,
    [NUUDL_ID]                        BIGINT         NOT NULL,
    [DWCreatedDate]                   DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_cimindividual] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_cimindividual]
    ON [sourceNuudlDawn].[cimindividual];

