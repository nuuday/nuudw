CREATE TABLE [meta].[DWRelations] (
    [TableName]                       NVARCHAR (128) NULL,
    [DimensionName]                   NVARCHAR (128) NULL,
    [TableColumnName]                 NVARCHAR (128) NULL,
    [DimensionColumnMappingName]      NVARCHAR (128) NULL,
    [RolePlayingDimensionName]        NVARCHAR (128) NULL,
    [IsSCD2DimensionFlag]             NVARCHAR (10)  NULL,
    [IsSCD2CompositeKeyDimensionFlag] NVARCHAR (10)  NULL,
    [ColumnOrdinalPosition]           INT            NULL,
    [IsNewDimensionFlag]              NVARCHAR (128) NULL,
    [DefaultErrorValue]               NVARCHAR (128) NULL
);

