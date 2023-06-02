CREATE TABLE [sourceCubusBivod].[OTT_STREAMLOG_History] (
    [ID]                    BIGINT          NOT NULL,
    [LOG_ID]                BIGINT          NULL,
    [STREAMED_AT]           DATETIME        NULL,
    [CUSTOMER_NUMBER]       NVARCHAR (32)   NULL,
    [CONTENT_ID]            NVARCHAR (256)  NULL,
    [CONTENT_TYPE]          NVARCHAR (256)  NULL,
    [CONTENT_DESCRIPTION]   NVARCHAR (1000) NULL,
    [CLIENT_TYPE]           NVARCHAR (256)  NULL,
    [CLIENT_UID]            NVARCHAR (256)  NULL,
    [IP]                    NVARCHAR (64)   NULL,
    [YOUSEE_IP]             DECIMAL (1)     NULL,
    [CUSTOMER_ORIGIN]       NVARCHAR (256)  NULL,
    [PRODUCT_TYPE]          NVARCHAR (256)  NULL,
    [STREAM_START]          DATETIME        NULL,
    [STREAM_END]            DATETIME        NULL,
    [IMPORT_DATE]           DATE            NULL,
    [PERSONA]               BIGINT          NULL,
    [DWIsCurrent]           BIT             NULL,
    [DWValidFromDate]       DATETIME2 (7)   NOT NULL,
    [DWValidToDate]         DATETIME2 (7)   NULL,
    [DWCreatedDate]         DATETIME2 (7)   NULL,
    [DWModifiedDate]        DATETIME2 (7)   NULL,
    [DWIsDeletedInSource]   BIT             NULL,
    [DWDeletedInSourceDate] DATETIME2 (7)   NULL,
    CONSTRAINT [PK_OTT_STREAMLOG_History] PRIMARY KEY NONCLUSTERED ([ID] ASC, [DWValidFromDate] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_OTT_STREAMLOG_History]
    ON [sourceCubusBivod].[OTT_STREAMLOG_History];

