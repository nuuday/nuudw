CREATE TABLE [nuuMeta].[SourceObjectExtendedAttributes] (
    [ID]                    INT                                                IDENTITY (1, 1) NOT NULL,
    [SourceObjectID]        INT                                                NULL,
    [SourceColumn]          [sysname]                                          NOT NULL,
    [SourceColumnAttribute] [sysname]                                          NOT NULL,
    [DestinationColumn]     [sysname]                                          NOT NULL,
    [ValidFrom]             DATETIME2 (7) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_SourceObjectExtendedAttributes_ValidFrom] DEFAULT (sysutcdatetime()) NOT NULL,
    [ValidTo]               DATETIME2 (7) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_SourceObjectExtendedAttributes_ValidTo] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999')) NOT NULL,
    CONSTRAINT [PK_SourceObjectExtendedAttributes] PRIMARY KEY CLUSTERED ([ID] ASC),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[nuuMeta].[SourceObjectExtendedAttributes_History], DATA_CONSISTENCY_CHECK=ON));

