CREATE TABLE [nuuMeta].[SourceObjectExtendedAttributes_History] (
    [ID]                    INT           NOT NULL,
    [SourceObjectID]        INT           NULL,
    [SourceColumn]          [sysname]     NOT NULL,
    [SourceColumnAttribute] [sysname]     NOT NULL,
    [DestinationColumn]     [sysname]     NOT NULL,
    [ValidFrom]             DATETIME2 (7) NOT NULL,
    [ValidTo]               DATETIME2 (7) NOT NULL
);


GO
CREATE CLUSTERED INDEX [ix_SourceObjectExtendedAttributes_History]
    ON [nuuMeta].[SourceObjectExtendedAttributes_History]([ValidTo] ASC, [ValidFrom] ASC) WITH (DATA_COMPRESSION = PAGE);

