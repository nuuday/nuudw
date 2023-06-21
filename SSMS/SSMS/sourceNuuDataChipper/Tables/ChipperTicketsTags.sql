CREATE TABLE [sourceNuuDataChipper].[ChipperTicketsTags] (
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
    [DWCreatedDate]             DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_ChipperTicketsTags] PRIMARY KEY NONCLUSTERED ([SRC_DWValidFromDate] ASC, [id] ASC, [tags] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ChipperTicketsTags]
    ON [sourceNuuDataChipper].[ChipperTicketsTags];

