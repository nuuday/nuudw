CREATE TABLE [sourceNuudlNetCracker].[ibsnrmlcharacteristic_History] (
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
    [DWIsCurrent]                BIT            NULL,
    [DWValidFromDate]            DATETIME2 (7)  NOT NULL,
    [DWValidToDate]              DATETIME2 (7)  NULL,
    [DWCreatedDate]              DATETIME2 (7)  NULL,
    [DWModifiedDate]             DATETIME2 (7)  NULL,
    [DWIsDeletedInSource]        BIT            NULL,
    [DWDeletedInSourceDate]      DATETIME2 (7)  NULL,
    CONSTRAINT [PK_ibsnrmlcharacteristic_History] PRIMARY KEY NONCLUSTERED ([NUUDL_ID] ASC, [DWValidFromDate] ASC)
);




GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ibsnrmlcharacteristic_History]
    ON [sourceNuudlNetCracker].[ibsnrmlcharacteristic_History];


GO
CREATE NONCLUSTERED INDEX [NCIX_ibsnrmlcharacteristic_History__DWIsCurrent_id]
    ON [sourceNuudlNetCracker].[ibsnrmlcharacteristic_History]([DWIsCurrent] ASC, [name] ASC, [product_instance_id] ASC)
    INCLUDE([value_json__corrupt_record], [NUUDL_ID]);

