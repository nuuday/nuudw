CREATE TABLE [sourceNuuDataChipper].[ChipperTicketsEventLog] (
    [eventLog.eventType]            NVARCHAR (500) NOT NULL,
    [eventLog.source.applicationId] NVARCHAR (50)  NULL,
    [eventLog.source.userId]        NVARCHAR (25)  NULL,
    [id]                            NVARCHAR (15)  NOT NULL,
    [eventLog.timestamp]            NVARCHAR (30)  NOT NULL,
    [sourceFilename]                NVARCHAR (200) NULL,
    [processedTimestamp]            DATETIME       NULL,
    [hour]                          INT            NULL,
    [quarterhour]                   BIGINT         NULL,
    [SRC_DWSourceFilePath]          NVARCHAR (500) NULL,
    [SRC_DWIsCurrent]               BIT            NULL,
    [SRC_DWValidFromDate]           DATETIME2 (7)  NOT NULL,
    [SRC_DWValidToDate]             DATETIME2 (7)  NULL,
    [SRC_DWCreatedDate]             DATETIME2 (7)  NULL,
    [SRC_DWModifiedDate]            DATETIME2 (7)  NULL,
    [SRC_DWIsDeletedInSource]       BIT            NULL,
    [SRC_DWDeletedInSourceDate]     DATETIME2 (7)  NULL,
    [eventLog.source.error.userId]  NVARCHAR (100) NULL,
    [DWCreatedDate]                 DATETIME2 (7)  DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_ChipperTicketsEventLog] PRIMARY KEY NONCLUSTERED ([SRC_DWValidFromDate] ASC, [eventLog.eventType] ASC, [eventLog.timestamp] ASC, [id] ASC)
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ChipperTicketsEventLog]
    ON [sourceNuuDataChipper].[ChipperTicketsEventLog];

