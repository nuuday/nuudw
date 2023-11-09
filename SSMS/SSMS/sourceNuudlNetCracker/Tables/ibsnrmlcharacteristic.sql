﻿CREATE TABLE [sourceNuudlNetCracker].[ibsnrmlcharacteristic] (
    [name]                       NVARCHAR (300) NULL,
    [product_instance_id]        NVARCHAR (36)  NULL,
    [product_offering_char_id]   NVARCHAR (36)  NULL,
    [product_spec_char_id]       NVARCHAR (36)  NULL,
    [value_json__corrupt_record] NVARCHAR (300) NULL,
    [attribute_id]               NVARCHAR (36)  NULL,
    [is_deleted]                 BIT            NULL,
    [last_modified_ts]           DATETIME2 (7)  NULL,
    [NUUDL_ValidFrom]            DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]              DATETIME2 (7)  NULL,
    [NUUDL_IsCurrent]            BIT            NULL,
    [NUUDL_ID]                   BIGINT         NOT NULL,
    [NUUDL_CuratedBatchID]       BIGINT         NULL,
    [DWCreatedDate]              DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_ibsnrmlcharacteristic] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ibsnrmlcharacteristic]
    ON [sourceNuudlNetCracker].[ibsnrmlcharacteristic];

