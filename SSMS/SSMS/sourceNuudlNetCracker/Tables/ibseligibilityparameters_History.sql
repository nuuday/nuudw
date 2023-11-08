CREATE TABLE [sourceNuudlNetCracker].[ibseligibilityparameters_History] (
    [id]                      NVARCHAR (36) NULL,
    [market_id]               NVARCHAR (36) NULL,
    [distribution_channel_id] NVARCHAR (36) NULL,
    [customer_category_id]    NVARCHAR (36) NULL,
    [brand_id]                NVARCHAR (36) NULL,
    [is_deleted]              BIT           NULL,
    [last_modified_ts]        DATETIME2 (7) NULL,
    [is_current]              BIT           NULL,
    [NUUDL_ValidTo]           DATETIME2 (7) NULL,
    [NUUDL_ValidFrom]         DATETIME2 (7) NULL,
    [NUUDL_IsCurrent]         BIT           NULL,
    [NUUDL_ID]                BIGINT        NOT NULL,
    [NUUDL_CuratedBatchID]    BIGINT        NULL,
    [DWIsCurrent]             BIT           NULL,
    [DWValidFromDate]         DATETIME2 (7) NOT NULL,
    [DWValidToDate]           DATETIME2 (7) NULL,
    [DWCreatedDate]           DATETIME2 (7) NULL,
    [DWModifiedDate]          DATETIME2 (7) NULL,
    [DWIsDeletedInSource]     BIT           NULL,
    [DWDeletedInSourceDate]   DATETIME2 (7) NULL,
    CONSTRAINT [PK_ibseligibilityparameters_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ibseligibilityparameters_History]
    ON [sourceNuudlNetCracker].[ibseligibilityparameters_History];

