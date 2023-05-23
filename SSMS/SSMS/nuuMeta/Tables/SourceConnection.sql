CREATE TABLE [nuuMeta].[SourceConnection] (
    [ID]                    INT                                                IDENTITY (1, 1) NOT NULL,
    [SourceConnectionType]  NVARCHAR (250)                                     CONSTRAINT [DF_SourceConnections_ConnectionType] DEFAULT ('') NOT NULL,
    [SourceConnectionName]  NVARCHAR (250)                                     CONSTRAINT [DF_SourceConnections_Name] DEFAULT ('') NOT NULL,
    [DestinationSchemaName] NVARCHAR (100)                                     CONSTRAINT [DF_SourceConnections_ExtractSchemaName] DEFAULT ('') NOT NULL,
    [ValidFrom]             DATETIME2 (7) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_SourceConnection_ValidFrom] DEFAULT (sysutcdatetime()) NOT NULL,
    [ValidTo]               DATETIME2 (7) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_SourceConnection_ValidTo] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999')) NOT NULL,
    CONSTRAINT [PK_SourceConnection] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [fk_ConnectionType] FOREIGN KEY ([SourceConnectionType]) REFERENCES [nuuMeta].[ValidConnectionType] ([ConnectionType]),
    CONSTRAINT [AK_SourceConnections_Name] UNIQUE NONCLUSTERED ([SourceConnectionName] ASC),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[nuuMeta].[SourceConnection_History], DATA_CONSISTENCY_CHECK=ON));

