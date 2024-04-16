CREATE TABLE [nuuMeta].[SourceObject] (
    [ID]                         INT                                                IDENTITY (1, 1) NOT NULL,
    [SourceConnectionName]       NVARCHAR (250)                                     NOT NULL,
    [SourceCatalogName]          NVARCHAR (200)                                     NULL DEFAULT (''),
    [SourceSchemaName]           NVARCHAR (200)                                     NOT NULL,
    [SourceObjectName]           NVARCHAR (200)                                     NOT NULL,
    [ExtractPattern]             NVARCHAR (100)                                     CONSTRAINT [DF_SourceObject_ExtractPattern] DEFAULT (N'Standard') NOT NULL,
    [ExtractSQLFilter]           NVARCHAR (MAX)                                     CONSTRAINT [DF_SourceObject_ExtractSQLFilter] DEFAULT ('') NOT NULL,
    [PrimaryKeyColumns]          NVARCHAR (MAX)                                     CONSTRAINT [DF_SourceObject_PrimaryKeyColumns] DEFAULT ('') NOT NULL,
    [HistoryType]                NVARCHAR (30)                                      CONSTRAINT [DF_SourceObject_HistoryType] DEFAULT ('None') NOT NULL,
    [HistoryTrackingColumns]     NVARCHAR (MAX)                                     CONSTRAINT [DF_SourceObject_HistoryTrackingColumns] DEFAULT ('') NOT NULL,
    [NuuDLJobcode]               NVARCHAR (512)                                     CONSTRAINT [DF_SourceObject_NuuDLJobcode] DEFAULT ('') NOT NULL,
    [SourceQuery]                NVARCHAR (MAX)                                     DEFAULT ('') NOT NULL,
    [SourceIsReadyQuery]         NVARCHAR (MAX)                                     DEFAULT ('SELECT 1 AS IsReady') NOT NULL,
    [WatermarkColumnName]        NVARCHAR (128)                                     DEFAULT ('') NOT NULL,
    [WatermarkIsDate]            BIT                                                DEFAULT ((0)) NOT NULL,
    [WatermarkLastValue]         NVARCHAR (50)                                      DEFAULT ((0)) NOT NULL,
    [WatermarkRollingWindowDays] INT                                                DEFAULT ((0)) NOT NULL,
    [WatermarkInQuery]           NVARCHAR (500)                                     DEFAULT ('') NOT NULL,
    [ValidFrom]                  DATETIME2 (7) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_SourceObject_ValidFrom] DEFAULT (sysutcdatetime()) NOT NULL,
    [ValidTo]                    DATETIME2 (7) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_SourceObject_ValidTo] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999')) NOT NULL,
    CONSTRAINT [PK_SourceObject] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [fk_ExtractPattern] FOREIGN KEY ([ExtractPattern]) REFERENCES [nuuMeta].[ValidExtractPattern] ([ExtractPattern]),
    CONSTRAINT [fk_HistoryType] FOREIGN KEY ([HistoryType]) REFERENCES [nuuMeta].[ValidHistoryType] ([HistoryType]),
    CONSTRAINT [fk_SourceConnectionName] FOREIGN KEY ([SourceConnectionName]) REFERENCES [nuuMeta].[SourceConnection] ([SourceConnectionName]),
    CONSTRAINT [AK_SourceObject_SourceConnectionName_SchemaName_ObjectName] UNIQUE NONCLUSTERED ([SourceConnectionName] ASC, [SourceSchemaName] ASC, [SourceObjectName] ASC),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[nuuMeta].[SourceObject_History], DATA_CONSISTENCY_CHECK=ON));



