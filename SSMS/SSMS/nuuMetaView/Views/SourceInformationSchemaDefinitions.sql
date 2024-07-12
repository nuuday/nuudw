
CREATE VIEW [nuuMetaView].[SourceInformationSchemaDefinitions] AS

WITH ExtractSchema AS
	(
		SELECT
			obj.ID AS SourceObjectID,
			eis.SourceSystemTypeName,
			eis.TableCatalogName,
			eis.SchemaName,
			eis.TableName,
			eis.ColumnName,
			eis.OrdinalPositionNumber,
			CASE 
				WHEN con.IsFileObject = 1 AND eis.DataTypeName = 'STRING' THEN 'nvarchar'
				WHEN con.IsFileObject = 1 AND eis.DataTypeName = 'SINGLE' THEN 'decimal'
				WHEN con.IsFileObject = 1 AND eis.DataTypeName = 'INT16' THEN 'smallint'
				WHEN con.IsFileObject = 1 AND eis.DataTypeName = 'INT32' THEN 'int'
				WHEN con.IsFileObject = 1 AND eis.DataTypeName = 'INT64' THEN 'bigint'
				WHEN con.IsFileObject = 1 AND eis.DataTypeName = 'BOOLEAN' THEN 'bit'
				WHEN con.IsFileObject = 1 AND eis.DataTypeName = 'DOUBLE' THEN 'decimal'
				WHEN con.IsFileObject = 1 AND eis.DataTypeName = 'DECIMAL' THEN 'decimal'
				WHEN con.IsFileObject = 1 AND eis.DataTypeName = 'GUID' THEN 'uniqueidentifier'
				WHEN con.IsFileObject = 1 AND eis.DataTypeName = 'DATETIME' THEN 'datetime'
				WHEN con.IsFileObject = 1 AND eis.DataTypeName = 'DATETIMEOFFSET' THEN 'datetimeoffset'
				WHEN con.IsFileObject = 1 AND eis.DataTypeName = 'TIMESPAN' THEN 'bigint'
				WHEN con.IsFileObject = 1 AND eis.DataTypeName = 'BYTE[]' THEN 'varbinary'
				WHEN eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND eis.DataTypeName = 'STRING' THEN 'nvarchar'
				WHEN eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND eis.DataTypeName = 'DOUBLE' THEN 'float'
				WHEN eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND eis.DataTypeName LIKE 'DECIMAL%' THEN 'decimal'
				WHEN eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND eis.DataTypeName = 'FLOAT' THEN 'float'
				WHEN eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND eis.DataTypeName = 'SHORT' THEN 'smallint'
				WHEN eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND eis.DataTypeName = 'INT' THEN 'int'
				WHEN eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND eis.DataTypeName = 'LONG' THEN 'bigint'
				WHEN eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND eis.DataTypeName = 'BOOLEAN' THEN 'bit'
				WHEN eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND eis.DataTypeName = 'DATE' THEN 'date'
				WHEN eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND eis.DataTypeName = 'TIMESTAMP' THEN 'datetime2'
				WHEN eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND eis.DataTypeName = 'map<string,string>' THEN 'nvarchar'
				WHEN eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND eis.DataTypeName like 'struct%' THEN 'nvarchar'
				WHEN eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND eis.DataTypeName like 'array%' THEN 'nvarchar'
				WHEN eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND eis.DataTypeName like 'variant%' THEN 'nvarchar'
				WHEN eis.DataTypeName = 'VARCHAR' THEN 'NVARCHAR'
				WHEN eis.DataTypeName = 'CHAR' THEN 'NVARCHAR'
				WHEN eis.DataTypeName = 'NCHAR' THEN 'NVARCHAR'
				WHEN eis.DataTypeName = 'LONG' AND eis.SourceSystemTypeName = 'Oracle' THEN 'NVARCHAR'
				WHEN eis.DataTypeName = 'MONEY' THEN 'DECIMAL'
				WHEN eis.DataTypeName = 'NUMBER' THEN 'DECIMAL'
				WHEN eis.DataTypeName = 'FLOAT' THEN 'DECIMAL'
				WHEN eis.DataTypeName = 'TIMESTMP' AND eis.SourceSystemTypeName = 'Db2' THEN 'DATETIME2'
				WHEN eis.DataTypeName LIKE 'TIMESTAMP%' AND eis.SourceSystemTypeName = 'Oracle' THEN 'DATETIME2'
				WHEN eis.DataTypeName = 'DATE' AND eis.SourceSystemTypeName = 'Oracle' THEN 'DATETIME2'
				WHEN eis.DataTypeName = 'VARCHAR2' THEN 'NVARCHAR'
				WHEN eis.DataTypeName = 'ORDIMAGE' THEN 'NVARCHAR'
				WHEN eis.DataTypeName = 'NVARCHAR2' THEN 'NVARCHAR'
				WHEN eis.DataTypeName = 'TIMESTAMP' THEN 'BIGINT'
				WHEN eis.DataTypeName = 'IMAGE' THEN 'NVARCHAR'
				WHEN eis.DataTypeName = 'CHARACTER' THEN 'VARCHAR'
				WHEN eis.DataTypeName = 'NATIONAL CHARACTER' THEN 'VARCHAR'
				WHEN eis.DataTypeName IN ('DEC', 'DECIMAL') AND eis.SourceSystemTypeName = 'Db2' THEN 'DECIMAL'
				WHEN eis.DataTypeName = 'NUMERIC' THEN 'DECIMAL'
				ELSE eis.DataTypeName
			END AS DataTypeName,
			CASE
				WHEN eis.DataTypeName = 'STRING' AND eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND eis.ColumnName LIKE '%id'  THEN 50
				WHEN eis.DataTypeName = 'STRING' AND eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND eis.ColumnName IN ('Description')  THEN -1
				WHEN eis.DataTypeName = 'STRING' AND eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake'  THEN 500
				WHEN eis.DataTypeName = 'map<string,string>' AND eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake'  THEN -1
				WHEN eis.DataTypeName like 'struct%' AND eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake'  THEN -1
				WHEN eis.DataTypeName like 'array%' AND eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake'  THEN -1
				WHEN eis.DataTypeName like 'variant%' AND eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake'  THEN -1
				WHEN eis.DataTypeName = 'LONG' AND eis.SourceSystemTypeName = 'Oracle' THEN -1
				ELSE [eis].MaximumLenghtNumber
			END AS MaximumLenghtNumber,
			CASE				
				WHEN eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND DataTypeName like 'decimal%' THEN SUBSTRING(DataTypeName,CHARINDEX('(',DataTypeName )+1, CHARINDEX(',',DataTypeName )-CHARINDEX('(',DataTypeName )-1)
				WHEN eis.DataTypeName = 'FLOAT' AND [eis].NumericPrecisionNumber > 36 THEN 36
				ELSE [eis].NumericPrecisionNumber
			END AS NumericPrecisionNumber,
			CASE				
				WHEN eis.SourceSystemTypeName = 'AzureDatabricksDeltaLake' AND DataTypeName like 'decimal%' THEN SUBSTRING(DataTypeName,CHARINDEX(',',DataTypeName )+1, CHARINDEX(')',DataTypeName )-CHARINDEX(',',DataTypeName )-1)
				ELSE [eis].NumericScaleNumber
			END AS NumericScaleNumber,
			COALESCE(IIF( pk.Value IS NULL, NULL, ROW_NUMBER() OVER (PARTITION BY [eis].SourceObjectID ORDER BY pk.ordinal )), KeySequenceNumber) AS KeySequenceNumber,
			DataTypeName AS OriginalDataTypeName
		FROM [nuuMeta].[SourceInformationSchema] eis
		LEFT JOIN [nuuMeta].SourceObject obj
			ON obj.ID = eis.SourceObjectID
		LEFT JOIN [nuuMetaView].SourceConnectionDefinitions con
			ON con.SourceConnectionName = obj.SourceConnectionName
		OUTER APPLY (
			SELECT sp.value, sp.ordinal
			FROM STRING_SPLIT(obj.PrimaryKeyColumns,',',1) sp
			WHERE CAST(value AS nvarchar(128)) = eis.ColumnName
		) pk

), PrepareData AS (

	SELECT DISTINCT
		SourceSystemTypeName,
		TableCatalogName,
		es.SchemaName,
		obj.SourceObjectName AS TableName,
		es.ColumnName,
		OrdinalPositionNumber,
		IIF( KeySequenceNumber IS NOT NULL, ' NOT NULL', ' NULL' ) NullableName,
		DataTypeName,
		IIF( DataTypeName = 'NVARCHAR' AND ISNULL( es.MaximumLenghtNumber, 4001 ) >= 4000, '4000', es.MaximumLenghtNumber ) AS MaximumLenghtNumber,
		IIF( DataTypeName = 'DECIMAL' AND NumericPrecisionNumber IS NULL, '36', NumericPrecisionNumber ) AS NumericPrecisionNumber,
		IIF( DataTypeName = 'DECIMAL' AND NumericScaleNumber IS NULL, '12', NumericScaleNumber ) AS NumericScaleNumber,
		KeySequenceNumber,
		es.SourceObjectID,
		con.ID AS SourceConnectionID,
		CASE DataTypeName
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
			WHEN 'smallint' THEN 'Int16'
			WHEN 'tinyint' THEN 'Int16'
			WHEN 'uniqueidentifier' THEN 'Guid'
			WHEN 'varbinary' THEN 'Byte[]'
			ELSE 'String'
		END 'ADFDataType',
		OriginalDataTypeName
	FROM ExtractSchema es
	LEFT JOIN nuuMeta.SourceObject obj
		ON obj.ID = es.SourceObjectID
	LEFT JOIN nuuMeta.SourceConnection con
		ON con.SourceConnectionName = obj.SourceConnectionName

), SourceData AS (

		SELECT
			SourceSystemTypeName,
			TableCatalogName,
			SchemaName,
			TableName,
			ColumnName,
			OrdinalPositionNumber,
			IIF( DataTypeName IN ('nvarchar'), 'NVARCHAR', UPPER( DataTypeName ) ) +
				CASE
					WHEN DataTypeName IN ('object', 'float', 'real') OR DataTypeName LIKE '%int%' OR DataTypeName LIKE '%date%' THEN ''
					WHEN DataTypeName IN ('nvarchar') AND MaximumLenghtNumber = -1 THEN '(MAX)'
					WHEN DataTypeName IN ('varbinary') THEN '(MAX)'
					WHEN NumericPrecisionNumber IS NOT NULL AND DataTypeName NOT IN ('nvarchar', 'varchar') THEN ' (' + CAST( NumericPrecisionNumber AS VARCHAR(50) ) + ', ' + CAST( NumericScaleNumber AS VARCHAR(50) ) + ')'
					WHEN MaximumLenghtNumber IS NOT NULL THEN ' (' + CAST( MaximumLenghtNumber AS VARCHAR(50) ) + ')'
					ELSE ''
				END AS FullDataTypeName,
			NullableName,
			DataTypeName,
			MaximumLenghtNumber,
			NumericPrecisionNumber,
			NumericScaleNumber,
			IIF( KeySequenceNumber IS NOT NULL, ROW_NUMBER() OVER (PARTITION BY SourceObjectID ORDER BY ISNULL( KeySequenceNumber, 999999 )), NULL ) KeySequenceNumber,
			SourceObjectID,
			SourceConnectionID,
			ADFDataType,
			OriginalDataTypeName
		FROM PrepareData

	)

SELECT
	COALESCE( SourceData.TableCatalogName, SourceTable.TableCatalogName ) AS TableCatalogName,
	COALESCE( SourceData.SchemaName, SourceTable.SchemaName ) AS SchemaName,
	COALESCE( SourceData.TableName, SourceTable.TableName ) AS TableName,
	COALESCE( SourceData.ColumnName, SourceTable.ColumnName ) AS ColumnName,
	COALESCE( SourceData.OrdinalPositionNumber, SourceTable.OrdinalPositionNumber ) AS OrdinalPositionNumber,
	CASE WHEN SourceData.ColumnName IN ('NUUDL_ValidFrom','NUUDL_ValidTo') THEN 'DATETIME2' ELSE COALESCE( SourceData.FullDataTypeName, SourceTable.FullDataTypeName ) END AS FullDataTypeName,
	COALESCE( SourceData.NullableName, SourceTable.NullableName ) AS NullableName,
	CASE WHEN SourceData.ColumnName IN ('NUUDL_ValidFrom','NUUDL_ValidTo') THEN 'datetime2' ELSE COALESCE( SourceData.DataTypeName, SourceTable.DataTypeName ) END AS DataTypeName,
	CASE WHEN SourceData.ColumnName IN ('NUUDL_ValidFrom','NUUDL_ValidTo') THEN null ELSE COALESCE( SourceData.MaximumLenghtNumber, SourceTable.MaximumLenghtNumber ) END AS MaximumLenghtNumber,
	COALESCE( SourceData.NumericPrecisionNumber, SourceTable.NumericPrecisionNumber ) AS NumericPrecisionNumber,
	COALESCE( SourceData.NumericScaleNumber, SourceTable.NumericScaleNumber ) AS NumericScaleNumber,
	COALESCE( SourceData.KeySequenceNumber, SourceTable.KeySequenceNumber ) AS KeySequenceNumber,
	COALESCE( SourceData.ADFDataType, SourceTable.ADFDataType ) AS ADFDataType,
	COALESCE( SourceData.SourceObjectID, SourceTable.SourceObjectID ) AS SourceObjectID,
	COALESCE( SourceData.SourceConnectionID, SourceTable.SourceConnectionID ) AS SourceConnectionID,
	COALESCE( SourceData.OriginalDataTypeName, SourceTable.OriginalDataTypeName ) AS OriginalDataTypeName
FROM SourceData
LEFT JOIN [nuuMeta].[SourceInformationSchema] SourceTable
	ON SourceData.SourceObjectID = SourceTable.SourceObjectID
		AND SourceData.ColumnName = SourceTable.ColumnName
WHERE 
	(COALESCE( SourceData.ColumnName, SourceTable.ColumnName ) IN ('NUUDL_ValidFrom','NUUDL_ValidTo','NUUDL_IsCurrent','NUUDL_CuratedBatchID','NUUDL_CuratedProcessedTimestamp','NUUDL_ID') 
		OR COALESCE( SourceData.ColumnName, SourceTable.ColumnName ) NOT LIKE 'NUUDL%')
	--AND COALESCE( SourceData.SourceObjectID, SourceTable.SourceObjectID )  =1566

/*
UNION ALL

SELECT
	so.SourceCatalogName AS TableCatalogName,
	so.SourceSchemaName AS SchemaName,
	so.SourceObjectName AS TableName,
	x.DestinationColumn AS ColumnName,
	NULL OrdinalPositionNumber,
	'NVARCHAR (500)' FullDataTypeName,
	'NULL' NullableName,
	'nvarchar' AS DataTypeName,
	500 MaximumLenghtNumber,
	null [NumericPrecisionNumber],
	null [NumericScaleNumber],
	null [KeySequenceNumber],
	'String' [ADFDataType],
	so.ID [SourceObjectID],
	sc.ID [SourceConnectionID],
	'map_attribute' [OriginalDataTypeName]
FROM nuuMeta.SourceObject so
INNER JOIN nuuMeta.SourceConnection sc ON sc.SourceConnectionName = so.SourceConnectionName
INNER JOIN nuuMeta.SourceObjectExtendedAttributes x
	ON x.SourceObjectID = so.ID
*/