CREATE TABLE [meta].[BusinessMatrixPackageDependency] (
    [ID]                     INT IDENTITY (1, 1) NOT NULL,
    [ChildBusinessMatrixID]  INT NULL,
    [ParentBusinessMatrixID] INT NULL,
    CONSTRAINT [PK__Business__3214EC27E8DE0D08] PRIMARY KEY CLUSTERED ([ID] ASC)
);

