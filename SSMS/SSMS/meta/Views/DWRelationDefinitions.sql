

CREATE VIEW [meta].[DWRelationDefinitions]

AS

SELECT TableName
      ,DimensionName
      ,TableColumnName
      ,DimensionColumnMappingName
      ,RolePlayingDimensionName
      ,IsSCD2DimensionFlag
      ,IsSCD2CompositeKeyDimensionFlag
      ,ColumnOrdinalPosition
      ,IsNewDimensionFlag
      ,DefaultErrorValue
FROM 
	meta.DWRelations