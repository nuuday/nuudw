CREATE TABLE [meta].[BusinessMatrixSCD2Setup] (
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    [BusinessMatrixID] INT            NOT NULL,
    [SCD2ColumnName]   NVARCHAR (500) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

