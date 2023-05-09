CREATE TABLE [meta].[SourceConnections] (
    [ID]                              INT            IDENTITY (1, 1) NOT NULL,
    [ConnectionType]                  NVARCHAR (250) CONSTRAINT [DF_SourceConnections_ConnectionType] DEFAULT ('') NOT NULL,
    [Name]                            NVARCHAR (250) CONSTRAINT [DF_SourceConnections_Name] DEFAULT ('') NOT NULL,
    [Provider]                        NVARCHAR (200) CONSTRAINT [DF_SourceConnections_Provider] DEFAULT ('') NOT NULL,
    [DataSource]                      NVARCHAR (100) CONSTRAINT [DF_SourceConnections_DataSource] DEFAULT ('') NOT NULL,
    [InitialCatalog]                  NVARCHAR (100) CONSTRAINT [DF_SourceConnections_InitialCatalog] DEFAULT ('') NOT NULL,
    [ConnectionString]                NVARCHAR (500) CONSTRAINT [DF_SourceConnections_ConnectionString] DEFAULT ('') NOT NULL,
    [ConnectionStringCustomComponent] NVARCHAR (500) CONSTRAINT [DF_SourceConnections_ConnectionStringCustomComponent] DEFAULT ('') NOT NULL,
    [ExtractSchemaName]               NVARCHAR (100) CONSTRAINT [DF_SourceConnections_ExtractSchemaName] DEFAULT ('') NOT NULL,
    [NavisionFlag]                    BIT            CONSTRAINT [DF_SourceConnections_NavisionFlag] DEFAULT ((0)) NOT NULL,
    [RemoveBracketsFlag]              BIT            CONSTRAINT [DF_SourceConnections_RemoveBracketsFlag] DEFAULT ((0)) NOT NULL,
    [ExcludeFlag]                     BIT            CONSTRAINT [DF_SourceConnections_ExcludeFlag] DEFAULT ((0)) NOT NULL,
    CONSTRAINT AK_SourceConnections_Name UNIQUE ([Name])
);
