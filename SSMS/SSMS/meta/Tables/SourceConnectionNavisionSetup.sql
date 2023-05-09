CREATE TABLE [meta].[SourceConnectionNavisionSetup] (
    [ID]                 INT            IDENTITY (1, 1) NOT NULL,
    [SourceConnectionID] INT            CONSTRAINT [DF_SourceConnectionNavisionSetup_SourceConnectionID] DEFAULT ((0)) NOT NULL,
    [CompanyName]        NVARCHAR (200) CONSTRAINT [DF_SourceObjectNavisionSetup_CompanyName] DEFAULT ('') NOT NULL,
    [ExtractFlag]        BIT            CONSTRAINT [DF_SourceObjectNavisionSetup_ExtractFlag] DEFAULT ((0)) NOT NULL
);

