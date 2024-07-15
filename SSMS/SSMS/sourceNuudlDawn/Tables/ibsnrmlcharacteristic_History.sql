CREATE TABLE [sourceNuudlDawn].[ibsnrmlcharacteristic_History] (
    [attribute_id]                    NVARCHAR (50)  NULL,
    [name]                            NVARCHAR (500) NULL,
    [op]                              NVARCHAR (500) NULL,
    [product_instance_id]             NVARCHAR (50)  NULL,
    [product_offering_char_id]        NVARCHAR (50)  NULL,
    [product_spec_char_id]            NVARCHAR (50)  NULL,
    [ts_ms]                           BIGINT         NULL,
    [value]                           NVARCHAR (MAX) NULL,
    [Snapshot]                        NVARCHAR (500) NULL,
    [Partition_Snapshot]              NVARCHAR (500) NULL,
    [NUUDL_CuratedBatchID]            INT            NULL,
    [NUUDL_CuratedProcessedTimestamp] NVARCHAR (500) NULL,
    [NUUDL_IsCurrent]                 BIT            NULL,
    [NUUDL_ValidFrom]                 DATETIME2 (7)  NULL,
    [NUUDL_ValidTo]                   DATETIME2 (7)  NULL,
    [NUUDL_ID]                        BIGINT         NOT NULL,
    [DWIsCurrent]                     BIT            NULL,
    [DWValidFromDate]                 DATETIME2 (7)  NOT NULL,
    [DWValidToDate]                   DATETIME2 (7)  NULL,
    [DWCreatedDate]                   DATETIME2 (7)  NULL,
    [DWModifiedDate]                  DATETIME2 (7)  NULL,
    [DWIsDeletedInSource]             BIT            NULL,
    [DWDeletedInSourceDate]           DATETIME2 (7)  NULL,
    CONSTRAINT [PK_ibsnrmlcharacteristic_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ibsnrmlcharacteristic_History]
    ON [sourceNuudlDawn].[ibsnrmlcharacteristic_History];

