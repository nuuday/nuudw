CREATE TABLE [sourceCubusBivod].[OTT_STREAMLOG] (
    [ID]                  BIGINT          NOT NULL,
    [LOG_ID]              BIGINT          NULL,
    [STREAMED_AT]         DATETIME        NULL,
    [CUSTOMER_NUMBER]     NVARCHAR (32)   NULL,
    [CONTENT_ID]          NVARCHAR (256)  NULL,
    [CONTENT_TYPE]        NVARCHAR (256)  NULL,
    [CONTENT_DESCRIPTION] NVARCHAR (1000) NULL,
    [CLIENT_TYPE]         NVARCHAR (256)  NULL,
    [CLIENT_UID]          NVARCHAR (256)  NULL,
    [IP]                  NVARCHAR (64)   NULL,
    [YOUSEE_IP]           DECIMAL (1)     NULL,
    [CUSTOMER_ORIGIN]     NVARCHAR (256)  NULL,
    [PRODUCT_TYPE]        NVARCHAR (256)  NULL,
    [STREAM_START]        DATETIME        NULL,
    [STREAM_END]          DATETIME        NULL,
    [IMPORT_DATE]         DATE            NULL,
    [PERSONA]             BIGINT          NULL,
    [DWCreatedDate]       DATETIME2 (7)   DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_OTT_STREAMLOG] PRIMARY KEY NONCLUSTERED ([ID] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_OTT_STREAMLOG]
    ON [sourceCubusBivod].[OTT_STREAMLOG];

