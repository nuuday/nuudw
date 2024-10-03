﻿CREATE TABLE [sourceNuudlDawn].[nrmaccountkeyname_History] (
    [account_num]                     NVARCHAR (500)  NULL,
    [name]                            NVARCHAR (500)  NULL,
    [op]                              NVARCHAR (500)  NULL,
    [ts_ms]                           BIGINT          NULL,
    [NUUDL_CuratedBatchID]            INT             NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (500)  NULL,
    [NUUDL_IsCurrent]                 BIT             NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)   NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)   NULL,
    [NUUDL_ID]                        BIGINT          NOT NULL,
    [DWIsCurrent]                     BIT             NULL,
    [DWValidFromDate]                 DATETIME2 (7)   NOT NULL,
    [DWValidToDate]                   DATETIME2 (7)   NULL,
    [DWCreatedDate]                   DATETIME2 (7)   NULL,
    [DWModifiedDate]                  DATETIME2 (7)   NULL,
    [DWIsDeletedInSource]             BIT             NULL,
    [DWDeletedInSourceDate]           DATETIME2 (7)   NULL,
    [NUUDL_IsDeleted]                 BIT             NULL,
    [NUUDL_DeleteType]                NVARCHAR (4000) NULL,
    [NUUDL_IsLatest]                  BIT             NULL,
    CONSTRAINT [PK_nrmaccountkeyname_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);






GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_nrmaccountkeyname_History]
    ON [sourceNuudlDawn].[nrmaccountkeyname_History];




GO
CREATE NONCLUSTERED INDEX [NCIX_nrmaccountkeyname_History__name_NUUDL_IsCurrent_DWIsCurrent]
    ON [sourceNuudlDawn].[nrmaccountkeyname_History]([name] ASC, [NUUDL_IsCurrent] ASC, [DWIsCurrent] ASC)
    INCLUDE([account_num]);

