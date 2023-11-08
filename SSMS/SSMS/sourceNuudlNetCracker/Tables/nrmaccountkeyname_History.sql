CREATE TABLE [sourceNuudlNetCracker].[nrmaccountkeyname_History] (
    [account_num]           NVARCHAR (300) NULL,
    [name]                  NVARCHAR (300) NULL,
    [NUUDL_ValidFrom]       DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]         DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]       BIT            NULL,
    [NUUDL_ID]              BIGINT         NOT NULL,
    [NUUDL_CuratedBatchID]  BIGINT         NULL,
    [DWIsCurrent]           BIT            NULL,
    [DWValidFromDate]       DATETIME2 (7)  NOT NULL,
    [DWValidToDate]         DATETIME2 (7)  NULL,
    [DWCreatedDate]         DATETIME2 (7)  NULL,
    [DWModifiedDate]        DATETIME2 (7)  NULL,
    [DWIsDeletedInSource]   BIT            NULL,
    [DWDeletedInSourceDate] DATETIME2 (7)  NULL,
    CONSTRAINT [PK_nrmaccountkeyname_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_nrmaccountkeyname_History]
    ON [sourceNuudlNetCracker].[nrmaccountkeyname_History];

