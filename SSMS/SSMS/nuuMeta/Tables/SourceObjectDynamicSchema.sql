CREATE TABLE [nuuMeta].[SourceObjectDynamicSchema] (
    [ID]               INT                                                IDENTITY (1, 1) NOT NULL,
    [SourceObjectID]   INT                                                NOT NULL,
    [SourceSchemaName] NVARCHAR (200)                                     NOT NULL,
    [Environment]      NVARCHAR (30)                                      NOT NULL,
    [ValidFrom]        DATETIME2 (7) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_SourceObjectDynamicSchema_ValidFrom] DEFAULT (sysutcdatetime()) NOT NULL,
    [ValidTo]          DATETIME2 (7) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_SourceObjectDynamicSchema_ValidTo] DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999')) NOT NULL,
    CONSTRAINT [PK_SourceObjectDynamicSchema] PRIMARY KEY CLUSTERED ([ID] ASC),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[nuuMeta].[SourceObjectDynamicSchema_History], DATA_CONSISTENCY_CHECK=ON));

