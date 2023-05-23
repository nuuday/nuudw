CREATE TABLE [nuuMeta].[SourceObject_History] (
    [ID]                         INT            NOT NULL,
    [SourceConnectionName]       NVARCHAR (250) NOT NULL,
    [SourceSchemaName]           NVARCHAR (200) NOT NULL,
    [SourceObjectName]           NVARCHAR (200) NOT NULL,
    [ExtractPattern]             NVARCHAR (100) NOT NULL,
    [ExtractSQLFilter]           NVARCHAR (MAX) NOT NULL,
    [PrimaryKeyColumns]          NVARCHAR (MAX) NOT NULL,
    [HistoryType]                NVARCHAR (30)  NOT NULL,
    [HistoryTrackingColumns]     NVARCHAR (MAX) NOT NULL,
    [NuuDLJobcode]               NVARCHAR (512) NOT NULL,
    [SourceQuery]                NVARCHAR (MAX) NOT NULL,
    [SourceIsReadyQuery]         NVARCHAR (MAX) NOT NULL,
    [WatermarkColumnName]        NVARCHAR (128) NOT NULL,
    [WatermarkIsDate]            BIT            NOT NULL,
    [WatermarkLastValue]         NVARCHAR (50)  NOT NULL,
    [WatermarkRollingWindowDays] INT            NOT NULL,
    [WatermarkInQuery]           NVARCHAR (500) NOT NULL,
    [ValidFrom]                  DATETIME2 (7)  NOT NULL,
    [ValidTo]                    DATETIME2 (7)  NOT NULL
);

