CREATE TABLE [nuuMeta].[SourceInformationSchema] (
    [SourceObjectID]           INT             NULL,
    [SourceSystemTypeName]     NVARCHAR (128)  NULL,
    [TableCatalogName]         NVARCHAR (128)  NULL,
    [SchemaName]               NVARCHAR (128)  NULL,
    [TableName]                NVARCHAR (200)  NULL,
    [ColumnName]               NVARCHAR (128)  NULL,
    [OrdinalPositionNumber]    INT             NULL,
    [FullDataTypeName]         NVARCHAR (4000) NULL,
    [NullableName]             NVARCHAR (128)  NULL,
    [DataTypeName]             NVARCHAR (4000) NULL,
    [MaximumLenghtNumber]      NVARCHAR (38)   NULL,
    [NumericPrecisionNumber]   INT             NULL,
    [NumericScaleNumber]       INT             NULL,
    [KeySequenceNumber]        INT             NULL,
    [ExtractSchemaName]        NVARCHAR (128)  NULL,
    [ADFDataType]              NVARCHAR (128)  NULL,
    [SourceConnectionID]       INT             NULL,
    [OriginalDataTypeName]     NVARCHAR (128)  NULL,
    [CreateTableFlag]          BIT             NULL,
    [TruncateBeforeDeployFlag] BIT             NULL,
    [PreserveHistoryFlag]      BIT             NULL,
    [NavisionFlag]             BIT             NULL
);





