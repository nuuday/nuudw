CREATE TABLE [meta].[TargetObjects] (
    [ID]                    INT            IDENTITY (1, 1) NOT NULL,
    [SourceObjectID]        INT            NOT NULL,
    [TargetConnectionID]    INT            NOT NULL,
    [ExtractPattern]        NVARCHAR (100) CONSTRAINT [DF_TargetObjects_ExtractPattern] DEFAULT (N'Standard') NOT NULL,
    [ExtractSQLFilter]      NVARCHAR (MAX) CONSTRAINT [DF_TargetObjects_ExtractSQLFilter] DEFAULT ('') NOT NULL,
    [PreserveHistoryFlag]   BIT            CONSTRAINT [DF_TargetObjects_PreserveHistoryFlag] DEFAULT ((0)) NOT NULL,
    [IncrementalFlag]       BIT            CONSTRAINT [DF_TargetObjects_IncrementalFlag] DEFAULT ((0)) NOT NULL,
    [SCD2ExtractFlag]       BIT            CONSTRAINT [DF_TargetObjects_SCD2ExtractFlag] DEFAULT ((0)) NOT NULL,
    [FileTargetFlag]        BIT            CONSTRAINT [DF_TargetObjects_FileExtractFlag] DEFAULT ((0)) NOT NULL,
    [AzureSqlDWFlag]        BIT            CONSTRAINT [DF_TargetObjects_AzureSqlDWFlag] DEFAULT ((0)) NOT NULL,
    [ExcludeFlag]           BIT            CONSTRAINT [DF_TargetObjects_ExcludeFlag] DEFAULT ((0)) NOT NULL,
    [ControllerExcludeFlag] BIT            CONSTRAINT [DF_TargetObjects_ControllerExcludeFlag] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TargetObjects] PRIMARY KEY CLUSTERED ([ID] ASC)
);





