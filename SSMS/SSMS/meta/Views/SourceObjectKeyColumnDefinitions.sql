



CREATE VIEW [meta].[SourceObjectKeyColumnDefinitions] AS 
SELECT 
       SourceObjectDefinitions.ConnectionName
	  ,SourceObjectDefinitions.ObjectName
	  ,SourceObjectKeyColumns.[SourceObjectID]
      ,SourceObjectKeyColumns.[SourceObjectKeyColumnName]
  FROM 
	meta.[SourceObjectKeyColumns]
  INNER JOIN
	meta.SourceObjectDefinitions
		ON SourceObjectDefinitions.SourceObjectID = SourceObjectKeyColumns.SourceObjectID
  WHERE
	SourceObjectDefinitions.KeyColumnFlag = 1