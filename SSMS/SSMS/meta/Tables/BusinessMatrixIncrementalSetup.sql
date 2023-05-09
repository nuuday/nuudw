CREATE TABLE [meta].[BusinessMatrixIncrementalSetup] (
    [ID]                   INT            IDENTITY (1, 1) NOT NULL,
    [BusinessMatrixID]     INT            NULL,
    [PrimaryKeyColumnName] NVARCHAR (200) NULL,
    CONSTRAINT [PK__Business__3214EC271402B3B8] PRIMARY KEY CLUSTERED ([ID] ASC)
);

