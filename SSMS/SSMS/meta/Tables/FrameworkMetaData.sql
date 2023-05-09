CREATE TABLE [meta].[FrameworkMetaData] (
    [ID]                   INT            IDENTITY (1, 1) NOT NULL,
    [SourceObjectID]       INT            NULL,
    [BusinessMatrixID]     INT            NULL,
    [TargetObjectID]       INT            NULL,
    [AverageDuration]      INT            CONSTRAINT [DF_FrameworkMetaData_AverageDuration] DEFAULT ((1)) NULL,
    [SQLScript]            NVARCHAR (MAX) NULL,
    [PartitionSQLScript]   NVARCHAR (MAX) NULL,
    [ConnectionSQLScript]  NVARCHAR (MAX) NULL,
    [DropTableSQLScript]   NVARCHAR (MAX) NULL,
    [CreateTableSQLScript] NVARCHAR (MAX) NULL,
    [AzureDWSQLScript]     NVARCHAR (MAX) NULL,
    CONSTRAINT [PK__Framewor__3214EC27261AF711] PRIMARY KEY CLUSTERED ([ID] ASC)
);





