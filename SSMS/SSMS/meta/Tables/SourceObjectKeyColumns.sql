CREATE TABLE [meta].[SourceObjectKeyColumns] (
    [ID]                        INT            IDENTITY (1, 1) NOT NULL,
    [SourceObjectID]            INT            NOT NULL,
    [SourceObjectKeyColumnName] NVARCHAR (250) NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

