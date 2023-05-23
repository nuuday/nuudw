CREATE TABLE [nuuMeta].[DWObject] (
    [ID]                     INT                                                IDENTITY (1, 1) NOT NULL,
    [DWObjectType]           NVARCHAR (30)                                      NOT NULL,
    [DWObjectName]           [sysname]                                          NOT NULL,
    [LoadPattern]            NVARCHAR (100)                                     NOT NULL,
    [LoadProcedure]          NVARCHAR (256)                                     CONSTRAINT [DF_DWObject_LoadProcedure] DEFAULT ('') NOT NULL,
    [HistoryTrackingColumns] NVARCHAR (MAX)                                     CONSTRAINT [DF_DWObject_HistoryTrackingColumns] DEFAULT ('') NOT NULL,
    [ValidFrom]              DATETIME2 (7) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_DWObject_ValidFrom] DEFAULT (sysutcdatetime()) NOT NULL,
    [ValidTo]                DATETIME2 (7) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_DWObject_ValidTo] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999')) NOT NULL,
    CONSTRAINT [PK_DWObject] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [fk_DWObjectType] FOREIGN KEY ([DWObjectType]) REFERENCES [nuuMeta].[ValidDWObjectType] ([DWObjectType]),
    CONSTRAINT [fk_LoadPattern] FOREIGN KEY ([LoadPattern]) REFERENCES [nuuMeta].[ValidLoadPattern] ([LoadPattern]),
    CONSTRAINT [AK_DWObjectType_DWObjectName] UNIQUE NONCLUSTERED ([DWObjectType] ASC, [DWObjectName] ASC),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[nuuMeta].[DWObject_History], DATA_CONSISTENCY_CHECK=ON));

