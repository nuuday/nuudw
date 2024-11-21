CREATE TABLE [nuuMeta].[PEDataLoadLog] (
    [id]          INT             IDENTITY (1, 1) NOT NULL,
    [LastLoad]    DATETIME        NULL,
    [NoOfRecords] INT             NULL,
    [TableName]   NVARCHAR (400)  NULL,
    [Status]      NVARCHAR (1000) NULL
);

