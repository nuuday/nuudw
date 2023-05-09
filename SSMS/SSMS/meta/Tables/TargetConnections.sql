CREATE TABLE [meta].[TargetConnections] (
    [ID]             INT            IDENTITY (1, 1) NOT NULL,
    [ConnectionType] NVARCHAR (250) CONSTRAINT [DF_TargetConnections_ConnectionType] DEFAULT ('') NOT NULL,
    [Name]           NVARCHAR (250) CONSTRAINT [DF_TargetConnections_Name] DEFAULT ('') NOT NULL,
    [ExcludeFlag]    BIT            CONSTRAINT [DF_TargetConnections_ExcludeFlag] DEFAULT ((0)) NOT NULL
);

