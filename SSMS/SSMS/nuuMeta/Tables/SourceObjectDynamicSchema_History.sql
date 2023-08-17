CREATE TABLE [nuuMeta].[SourceObjectDynamicSchema_History] (
    [ID]               INT            NOT NULL,
    [SourceObjectID]   INT            NOT NULL,
    [SourceSchemaName] NVARCHAR (200) NOT NULL,
    [Environment]      NVARCHAR (30)  NOT NULL,
    [ValidFrom]        DATETIME2 (7)  NOT NULL,
    [ValidTo]          DATETIME2 (7)  NOT NULL
);


GO
CREATE CLUSTERED INDEX [ix_SourceObjectDynamicSchema_History]
    ON [nuuMeta].[SourceObjectDynamicSchema_History]([ValidTo] ASC, [ValidFrom] ASC) WITH (DATA_COMPRESSION = PAGE);

