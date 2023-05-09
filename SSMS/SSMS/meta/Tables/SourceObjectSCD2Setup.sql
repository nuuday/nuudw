CREATE TABLE [meta].[SourceObjectSCD2Setup] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [SourceObjectID] INT            NOT NULL,
    [SCD2ColumnName] NVARCHAR (500) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

