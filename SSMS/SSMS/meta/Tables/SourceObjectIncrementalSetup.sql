CREATE TABLE [meta].[SourceObjectIncrementalSetup] (
    [ID]                                        INT            IDENTITY (1, 1) NOT NULL,
    [SourceObjectID]                            INT            NOT NULL,
    [IncrementalValueColumnDefinition]          NVARCHAR (500) CONSTRAINT [DF_SourceObjectIncrementalSetup_IncrementalValueColumnName] DEFAULT ('') NOT NULL,
    [IncrementalValueColumnDefinitionInExtract] NVARCHAR (500) CONSTRAINT [DF_SourceObjectIncrementalSetup_IncrementalValueColumnDefinitionInExtract] DEFAULT ('') NOT NULL,
    [IsDateFlag]                                BIT            CONSTRAINT [DF_SourceObjectIncrementalSetup_IsDateFlag] DEFAULT ((0)) NOT NULL,
    [LastValueLoaded]                           NVARCHAR (500) NOT NULL,
    [RollingWindowDays]                         INT            CONSTRAINT [DF_SourceObjectIncrementalSetup_RollingWindowNumber] DEFAULT ((0)) NULL,
    CONSTRAINT AK_SourceObjectIncrementalSetup_ID UNIQUE ([ID])
);



