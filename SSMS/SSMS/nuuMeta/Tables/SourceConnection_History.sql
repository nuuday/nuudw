CREATE TABLE [nuuMeta].[SourceConnection_History] (
    [ID]                    INT            NOT NULL,
    [SourceConnectionType]  NVARCHAR (250) NOT NULL,
    [SourceConnectionName]  NVARCHAR (250) NOT NULL,
    [DestinationSchemaName] NVARCHAR (100) NOT NULL,
    [ValidFrom]             DATETIME2 (7)  NOT NULL,
    [ValidTo]               DATETIME2 (7)  NOT NULL,
    [Environment]           NVARCHAR (30)  NULL
);



