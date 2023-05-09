CREATE TABLE [meta].[SourceObjects] (
    [ID]                       INT            IDENTITY (1, 1) NOT NULL,
    [SourceConnectionID]       INT            NOT NULL,
    [SchemaName]               NVARCHAR (200) NOT NULL,
    [ObjectName]               NVARCHAR (200) NOT NULL,
    [ExtractPattern]           NVARCHAR (100) CONSTRAINT [DF_SourceObjects_ExtractPattern] DEFAULT (N'Standard') NOT NULL,
    [ExtractSQLFilter]         NVARCHAR (MAX) CONSTRAINT [DF_SourceObjects_ExtractSQLFilter] DEFAULT ('') NOT NULL,
    [PreserveHistoryFlag]      BIT            CONSTRAINT [DF_SourceObjects_PreserveHistoryFlag] DEFAULT ((0)) NOT NULL,
    [FileExtractFlag]          BIT            CONSTRAINT [DF_SourceObjects_FileExtractFlag] DEFAULT ((0)) NOT NULL,
    [IncrementalFlag]          BIT            CONSTRAINT [DF_SourceObjects_IncrementalFlag] DEFAULT ((0)) NOT NULL,
    [PartitionFlag]            BIT            CONSTRAINT [DF_SourceObjects_ParallelizationFlag] DEFAULT ((0)) NOT NULL,
    [SCD2ExtractFlag]          BIT            CONSTRAINT [DF_SourceObjects_SCD2ExtractFlag] DEFAULT ((0)) NOT NULL,
    [KeyColumnFlag]            BIT            CONSTRAINT [DF_SourceObjects_KeyColumnFlag] DEFAULT ((0)) NOT NULL,
    [TruncateBeforeDeployFlag] BIT            CONSTRAINT [DF_SourceObjects_TruncateBeforeDeployFlag] DEFAULT ((1)) NOT NULL,
    [ControllerExcludeFlag]    BIT            CONSTRAINT [DF_SourceObjects_ControllerExcludeFlag] DEFAULT ((1)) NOT NULL,
    [TargetDestinationFlag]    BIT            CONSTRAINT [DF_SourceObjects_TargetDestinationFlag] DEFAULT ((0)) NOT NULL,
    [DWDestinationFlag]        BIT            CONSTRAINT [DF_SourceObjects_DWDestinationFlag] DEFAULT ((1)) NOT NULL,
    [ExcludeFlag]              BIT            CONSTRAINT [DF_SourceObjects_ExcludeFlag] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SourceObjects] PRIMARY KEY CLUSTERED ([ID] ASC),
	CONSTRAINT AK_SourceObjects_SourceConnectionID_SchemaName_ObjectName UNIQUE (SourceConnectionID,SchemaName,ObjectName)
);





