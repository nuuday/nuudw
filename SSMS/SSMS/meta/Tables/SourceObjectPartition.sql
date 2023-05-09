CREATE TABLE [meta].[SourceObjectPartition] (
    [ID]                             INT            IDENTITY (1, 1) NOT NULL,
    [SourceObjectID]                 INT            NOT NULL,
    [PartitionValueColumnDefinition] NVARCHAR (MAX) NOT NULL,
    [UseModulusFlag]                 BIT            CONSTRAINT [DF_SourceObjectPartition_UseModulusFlag] DEFAULT ((0)) NULL,
    [PartitionLowerBound]            NVARCHAR (200) NOT NULL,
    [PartitionUpperBound]            NVARCHAR (200) NOT NULL,
    CONSTRAINT [PK_SourceObjectPartition] PRIMARY KEY CLUSTERED ([ID] ASC)
);

