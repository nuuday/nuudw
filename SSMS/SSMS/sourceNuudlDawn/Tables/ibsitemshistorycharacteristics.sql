CREATE TABLE [sourceNuudlDawn].[ibsitemshistorycharacteristics] (
    [id]                         NVARCHAR (50)   NULL,
    [technology]                 NVARCHAR (4000) NULL,
    [international_phone_number] NVARCHAR (4000) NULL,
    [NUUDL_CuratedBatchID]       INT             NULL,
    [NUUDL_IsCurrent]            BIT             NULL,
    [NUUDL_ValidFrom]            DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]              DATETIME2 (7)   NULL,
    [NUUDL_ID]                   BIGINT          NOT NULL,
    [DWCreatedDate]              DATETIME2 (7)   DEFAULT (getdate()) NULL,
    [NUUDL_IsDeleted]            BIT             NULL,
    [NUUDL_DeleteType]           NVARCHAR (4000) NULL,
    [NUUDL_IsLatest]             BIT             NULL,
    CONSTRAINT [PK_ibsitemshistorycharacteristics] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);



