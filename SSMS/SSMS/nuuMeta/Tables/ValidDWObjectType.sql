CREATE TABLE [nuuMeta].[ValidDWObjectType] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [DWObjectType] NVARCHAR (30)  NOT NULL,
    [Description]  NVARCHAR (MAX) NULL,
    CONSTRAINT [AK_DWObjectType] UNIQUE NONCLUSTERED ([DWObjectType] ASC)
);

