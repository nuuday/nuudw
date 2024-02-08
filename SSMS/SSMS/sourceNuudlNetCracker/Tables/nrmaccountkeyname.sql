﻿CREATE TABLE [sourceNuudlNetCracker].[nrmaccountkeyname] (
    [account_num]          NVARCHAR (300) NULL,
    [name]                 NVARCHAR (300) NULL,
    [NUUDL_ValidFrom]      DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]        DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]      BIT            NULL,
    [NUUDL_ID]             BIGINT         NOT NULL,
    [NUUDL_CuratedBatchID] BIGINT         NULL,
    [DWCreatedDate]        DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_nrmaccountkeyname] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_nrmaccountkeyname]
    ON [sourceNuudlNetCracker].[nrmaccountkeyname];

