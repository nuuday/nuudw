CREATE TABLE [nuuMeta].[ValidExtractPattern] (
    [ID]             INT            IDENTITY (1, 1) NOT NULL,
    [ExtractPattern] NVARCHAR (100) NOT NULL,
    [Description]    NVARCHAR (MAX) NULL,
    CONSTRAINT [AK_ExtractPattern] UNIQUE NONCLUSTERED ([ExtractPattern] ASC)
);

