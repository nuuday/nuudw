CREATE TABLE [nuuMeta].[ValidConnectionType] (
    [ID]                  INT            IDENTITY (1, 1) NOT NULL,
    [ConnectionType]      NVARCHAR (250) NOT NULL,
    [DelimitedIdentifier] NVARCHAR (30)  NULL,
    [Description]         NVARCHAR (MAX) NULL,
    CONSTRAINT [AK_ConnectionType] UNIQUE NONCLUSTERED ([ConnectionType] ASC)
);

