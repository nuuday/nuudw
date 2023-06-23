CREATE TABLE [sourceNuuDataChipper].[ChipperTicketsTags_History] (
    [id]                        NVARCHAR (500) NOT NULL,
    [tags]                      NVARCHAR (500) NOT NULL,
    [sourceFilename]            NVARCHAR (500) NULL,
    [processedTimestamp]        DATETIME       NULL,
    [hour]                      INT            NULL,
    [quarterhour]               BIGINT         NULL,
    [SRC_DWSourceFilePath]      NVARCHAR (500) NULL,
    [SRC_DWIsCurrent]           BIT            NULL,
    [SRC_DWValidFromDate]       DATETIME2 (7)  NOT NULL,
    [SRC_DWValidToDate]         DATETIME2 (7)  NULL,
    [SRC_DWCreatedDate]         DATETIME2 (7)  NULL,
    [SRC_DWModifiedDate]        DATETIME2 (7)  NULL,
    [SRC_DWIsDeletedInSource]   BIT            NULL,
    [SRC_DWDeletedInSourceDate] DATETIME2 (7)  NULL,
    [DWIsCurrent]               BIT            NULL,
    [DWValidFromDate]           DATETIME2 (7)  NOT NULL,
    [DWValidToDate]             DATETIME2 (7)  NULL,
    [DWCreatedDate]             DATETIME2 (7)  NULL,
    [DWModifiedDate]            DATETIME2 (7)  NULL,
    [DWIsDeletedInSource]       BIT            NULL,
    [DWDeletedInSourceDate]     DATETIME2 (7)  NULL,
    CONSTRAINT [PK_ChipperTicketsTags_History] PRIMARY KEY NONCLUSTERED ([id] ASC, [tags] ASC, [SRC_DWValidFromDate] ASC, [DWValidFromDate] ASC)
);




GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ChipperTicketsTags_History]
    ON [sourceNuuDataChipper].[ChipperTicketsTags_History];

