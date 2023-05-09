
















CREATE VIEW [meta].[ExtractInformationSchemaDefinitions] AS


WITH ExtractSchema AS
(
SELECT 
	   ExtractInformationSchema.SourceObjectID
	  ,ExtractInformationSchema.SourceSystemTypeName
      ,TableCatalogName 
      ,ExtractInformationSchema.SchemaName
      ,TableName
      ,ColumnName
      ,OrdinalPositionNumber
	  ,IIF(SourceObjects.FileExtractFlag = 1, 
			  CASE DataTypeName
				WHEN 'STRING' THEN 'nvarchar'
				WHEN 'SINGLE' THEN 'tinyint'
				WHEN 'INT16' THEN 'tinyint'
				WHEN 'INT32' THEN 'int'
				WHEN 'INT64' THEN 'bigint'
				WHEN 'BOOLEAN' THEN 'bit'
				WHEN 'DOUBLE' THEN 'decimal'
				WHEN 'DECIMAL' THEN 'decimal'
				WHEN 'GUID' THEN 'uniqueidentifier'
				WHEN 'DATETIME' THEN 'datetime'
				WHEN 'DATETIMEOFFSET' THEN 'datetimeoffset'
				WHEN 'TIMESPAN' THEN 'bigint'
				WHEN 'BYTE[]' THEN 'varbinary'
				ELSE 'nvarchar'
			  END,
			  CASE 
			    WHEN DataTypeName = 'VARCHAR' THEN 'NVARCHAR'
				WHEN DataTypeName = 'CHAR' THEN 'NVARCHAR'
				WHEN DataTypeName = 'NCHAR' THEN 'NVARCHAR'
				WHEN DataTypeName = 'MONEY' THEN 'DECIMAL'
				WHEN DataTypeName = 'NUMBER' THEN 'DECIMAL'
				WHEN DataTypeName = 'FLOAT' THEN 'DECIMAL'
				WHEN DataTypeName = 'DATE' AND ExtractInformationSchema.SourceSystemTypeName = 'Oracle' THEN 'DATETIME2'
				WHEN DataTypeName = 'VARCHAR2' THEN 'NVARCHAR'
				WHEN DataTypeName = 'ORDIMAGE' THEN 'NVARCHAR'
				WHEN DataTypeName = 'NVARCHAR2' THEN 'NVARCHAR'
				WHEN DataTypeName = 'TIMESTAMP' THEN 'BIGINT'
				WHEN DataTypeName = 'IMAGE' THEN 'NVARCHAR'
				ELSE DataTypeName
			  END
		) AS DataTypeName
	  ,[ExtractInformationSchema].MaximumLenghtNumber
	  ,CASE
		WHEN DataTypeName = 'FLOAT' AND [ExtractInformationSchema].NumericPrecisionNumber > 36 THEN 36
		ELSE [ExtractInformationSchema].NumericPrecisionNumber 
	   END AS NumericPrecisionNumber
	  ,[ExtractInformationSchema].NumericScaleNumber
	  ,COALESCE(IIF(SourceObjectKeyColumns.ID IS NULL,NULL,ROW_NUMBER() OVER (PARTITION BY [ExtractInformationSchema].SourceObjectID  ORDER BY SourceObjectKeyColumns.ID desc)), KeySequenceNumber) AS KeySequenceNumber	 
 	  ,DataTypeName AS OriginalDataTypeName
	  ,COALESCE([ExtractInformationSchema].CreateTableFlag,SourceObjects.DWDestinationFlag) AS CreateTableFlag
	  ,COALESCE([ExtractInformationSchema].TruncateBeforeDeployFlag,SourceObjects.TruncateBeforeDeployFlag) AS TruncateBeforeDeployFlag
	  ,COALESCE([ExtractInformationSchema].PreserveHistoryFlag,SourceObjects.PreserveHistoryFlag) AS PreserveHistoryFlag
	  ,COALESCE([ExtractInformationSchema].NavisionFlag,SourceConnections.NavisionFlag) AS NavisionFlag
	  ,SourceObjects.FileExtractFlag
  FROM 
	[meta].[ExtractInformationSchema]   
  LEFT JOIN
		meta.SourceObjects
			ON SourceObjects.ID = [ExtractInformationSchema].SourceObjectID
  LEFT JOIN 
		meta.SourceConnections
			ON SourceConnections.ID = SourceObjects.SourceConnectionID
  LEFT JOIN
		meta.SourceObjectKeyColumns
			ON SourceObjectKeyColumns.SourceObjectID = [ExtractInformationSchema].SourceObjectID
			AND SourceObjectKeyColumns.SourceObjectKeyColumnName = [ExtractInformationSchema].ColumnName
		)

	,PrepareData AS
	(
	SELECT DISTINCT 
		   SourceSystemTypeName
		  ,TableCatalogName
		  ,ExtractSchema.SchemaName
		  ,SourceObjects.ObjectName AS TableName
		  ,ExtractSchema.ColumnName
		  ,OrdinalPositionNumber
		  ,IIF(KeySequenceNumber IS NOT NULL,' NOT NULL',' NULL') NullableName
		  ,DataTypeName
	      ,IIF(ExtractSchema.FileExtractFlag = 1 AND UPPER(DataTypeName) = 'NVARCHAR', 
			'500', 
			IIF(DataTypeName = 'NVARCHAR' AND ISNULL(ExtractSchema.MaximumLenghtNumber,4001) >= 4000,'4000',ExtractSchema.MaximumLenghtNumber)
		   ) AS MaximumLenghtNumber
		  ,IIF(ExtractSchema.FileExtractFlag = 1 AND UPPER(DataTypeName) = 'DECIMAL',
			'36',
			IIF(DataTypeName = 'DECIMAL' AND NumericPrecisionNumber IS NULL,'36',NumericPrecisionNumber) 
		   ) AS NumericPrecisionNumber
		  ,IIF(ExtractSchema.FileExtractFlag = 1 AND UPPER(DataTypeName) = 'DECIMAL',
			'12',
			IIF(DataTypeName = 'DECIMAL' AND NumericScaleNumber IS NULL,'12',NumericScaleNumber)
	       ) AS NumericScaleNumber
		  ,KeySequenceNumber
		  ,SourceConnections.ExtractSchemaName 
		  ,ExtractSchema.SourceObjectID 
		  ,SourceObjects.SourceConnectionID
		  ,CASE DataTypeName
				WHEN 'bigint' THEN 'Int64'
				WHEN 'char' THEN 'String'
				WHEN 'datetime' THEN 'Datetime'
				WHEN 'datetimeoffset' THEN 'Datetimeoffset'
				WHEN 'decimal' THEN 'Decimal'
				WHEN 'float' THEN 'Double'
				WHEN 'real' THEN 'Double'
				WHEN 'int' THEN 'Int32'
				WHEN 'money' THEN 'Decimal'
				WHEN 'nchar' THEN 'String'
				WHEN 'numeric' THEN 'Decimal'
				WHEN 'nvarchar' THEN 'String'
				WHEN 'smallint' then 'Int16'
				WHEN 'tinyint' THEN 'Int16'
				WHEN 'uniqueidentifier' THEN 'Guid'
				WHEN 'varbinary' THEN 'Byte[]'
				ELSE 'String'
			END 'ADFDataType'
		 ,IIF(SourceColumns.ColumnName IS NULL,0,1) AS TableHasColumnFilterFlag
		 ,IIF(SourceColumns2.ColumnName IS NULL,0,1) AS ColumnFilterFlag
		 ,OriginalDataTypeName
		 ,CreateTableFlag
	     ,ExtractSchema.TruncateBeforeDeployFlag
	     ,ExtractSchema.PreserveHistoryFlag
		 ,ExtractSchema.NavisionFlag
	FROM
		ExtractSchema
	LEFT JOIN
		meta.SourceObjects
			ON SourceObjects.ID = ExtractSchema.SourceObjectID
	LEFT JOIN 
		meta.SourceConnections
			ON SourceConnections.ID = SourceObjects.SourceConnectionID
	LEFT JOIN
		meta.SourceColumns
			ON SourceObjects.ID = SourceColumns.SourceObjectID
	LEFT JOIN
		meta.SourceColumns AS SourceColumns2
			ON ExtractSchema.ColumnName = SourceColumns2.ColumnName
			AND SourceObjects.ID = SourceColumns2.SourceObjectID
	)

	,SourceData AS 
	(
	SELECT 
		   SourceSystemTypeName
		  ,TableCatalogName
		  ,SchemaName
		  ,TableName
		  ,ColumnName
		  ,OrdinalPositionNumber
		  ,IIF(DataTypeName IN ('nvarchar'), 'NVARCHAR',UPPER(DataTypeName)) +  
			CASE 
				WHEN DataTypeName in ('object','float','real') OR DataTypeName like '%int%' OR DataTypeName like'%date%'
					THEN ''
				WHEN DataTypeName IN ('nvarchar') AND MaximumLenghtNumber = -1 
					THEN '(MAX)'
				WHEN DataTypeName IN ('varbinary')
					THEN '(MAX)'
				WHEN NumericPrecisionNumber IS NOT NULL 
					THEN ' (' + CAST(NumericPrecisionNumber AS VARCHAR(50)) + ', ' + CAST(NumericScaleNumber AS VARCHAR(50))+ ')'
				WHEN MaximumLenghtNumber IS NOT NULL 
					THEN ' (' + CAST(MaximumLenghtNumber AS VARCHAR(50)) + ')'																											
				ELSE '' 
			END AS FullDataTypeName
		  ,NullableName
		  ,DataTypeName
	      ,MaximumLenghtNumber
		  ,NumericPrecisionNumber
		  ,NumericScaleNumber
		  ,KeySequenceNumber
		  ,ExtractSchemaName 
		  ,SourceObjectID 
		  ,SourceConnectionID
		  ,ADFDataType
		 ,TableHasColumnFilterFlag
		 ,ColumnFilterFlag
		 ,OriginalDataTypeName
		 ,CreateTableFlag
	     ,TruncateBeforeDeployFlag
	     ,PreserveHistoryFlag
		 ,NavisionFlag
	FROM
		PrepareData
	)

		SELECT 
			 COALESCE(SourceData.SourceSystemTypeName, SourceTable.SourceSystemTypeName) AS SourceSystemTypeName
			,COALESCE(SourceData.TableCatalogName, SourceTable.TableCatalogName) AS TableCatalogName
			,COALESCE(SourceData.SchemaName, SourceTable.SchemaName) AS SchemaName
			,COALESCE(SourceData.TableName, SourceTable.TableName) AS TableName
			,COALESCE(SourceData.ColumnName, SourceTable.ColumnName) AS ColumnName
			,COALESCE(SourceData.OrdinalPositionNumber, SourceTable.OrdinalPositionNumber) AS OrdinalPositionNumber
			,COALESCE(SourceData.FullDataTypeName, SourceTable.FullDataTypeName) AS FullDataTypeName
			,COALESCE(SourceData.NullableName, SourceTable.NullableName) AS NullableName
			,COALESCE(SourceData.DataTypeName, SourceTable.DataTypeName) AS DataTypeName
			,COALESCE(SourceData.MaximumLenghtNumber, SourceTable.MaximumLenghtNumber) AS MaximumLenghtNumber
			,COALESCE(SourceData.NumericPrecisionNumber, SourceTable.NumericPrecisionNumber) AS NumericPrecisionNumber
			,COALESCE(SourceData.NumericScaleNumber, SourceTable.NumericScaleNumber) AS NumericScaleNumber
			,COALESCE(SourceData.KeySequenceNumber, SourceTable.KeySequenceNumber) AS KeySequenceNumber
			,COALESCE(SourceData.ExtractSchemaName, SourceTable.ExtractSchemaName) AS ExtractSchemaName
			,COALESCE(SourceData.ADFDataType, SourceTable.ADFDataType) AS ADFDataType
			,COALESCE(SourceData.SourceObjectID, SourceTable.SourceObjectID) AS SourceObjectID
			,COALESCE(SourceData.SourceConnectionID, SourceTable.SourceConnectionID) AS SourceConnectionID
			,COALESCE(SourceData.OriginalDataTypeName, SourceTable.OriginalDataTypeName) AS OriginalDataTypeName
			,SourceData.CreateTableFlag
			,SourceData.TruncateBeforeDeployFlag
			,SourceData.PreserveHistoryFlag
			,SourceData.NavisionFlag
		FROM SourceData
		LEFT JOIN [meta].[ExtractInformationSchema] SourceTable
			ON SourceData.SourceObjectID = SourceTable.SourceObjectID
				AND SourceData.ColumnName = SourceTable.ColumnName

		WHERE TableHasColumnFilterFlag = ColumnFilterFlag