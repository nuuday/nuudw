CREATE TABLE [sourceNuudlDawn].[ibsitemshistorycharacteristics_History] (
    [id]                         NVARCHAR (50)   NULL,
    [technology]                 NVARCHAR (4000) NULL,
    [international_phone_number] NVARCHAR (4000) NULL,
    [NUUDL_CuratedBatchID]       INT             NULL,
    [NUUDL_IsCurrent]            BIT             NULL,
    [NUUDL_ValidFrom]            DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]              DATETIME2 (7)   NULL,
    [NUUDL_ID]                   BIGINT          NOT NULL,
    [DWIsCurrent]                BIT             NULL,
    [DWValidFromDate]            DATETIME2 (7)   NOT NULL,
    [DWValidToDate]              DATETIME2 (7)   NULL,
    [DWCreatedDate]              DATETIME2 (7)   NULL,
    [DWModifiedDate]             DATETIME2 (7)   NULL,
    [DWIsDeletedInSource]        BIT             NULL,
    [DWDeletedInSourceDate]      DATETIME2 (7)   NULL,
    [NUUDL_IsDeleted]            BIT             NULL,
    [NUUDL_DeleteType]           NVARCHAR (4000) NULL,
    [NUUDL_IsLatest]             BIT             NULL,
    [phone_number]               NVARCHAR (4000) NULL,
    CONSTRAINT [PK_ibsitemshistorycharacteristics_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);





