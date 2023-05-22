CREATE TABLE [nuuMeta].[ValidLoadPattern] (
    [ID]          INT            IDENTITY (1, 1) NOT NULL,
    [LoadPattern] NVARCHAR (100) NOT NULL,
    [Description] NVARCHAR (MAX) NULL,
    CONSTRAINT [AK_LoadPattern] UNIQUE NONCLUSTERED ([LoadPattern] ASC)
);

