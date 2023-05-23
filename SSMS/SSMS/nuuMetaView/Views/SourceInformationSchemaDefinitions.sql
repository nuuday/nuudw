

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
			IIF( con.IsFileObject = 1,
				CASE eis.DataTypeName
					WHEN 'STRING' THEN 'nvarchar'
					WHEN 'SINGLE' THEN 'decimal'
					WHEN 'INT16' THEN 'smallint'
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
				END
			) AS DataTypeName,
			CASE
				WHEN eis.DataTypeName = 'LONG' AND eis.SourceSystemTypeName = 'Oracle' THEN -1
				ELSE [eis].MaximumLenghtNumber
			END AS MaximumLenghtNumber,
			CASE
				WHEN eis.DataTypeName = 'FLOAT' AND [eis].NumericPrecisionNumber > 36 THEN 36
				ELSE [eis].NumericPrecisionNumber
			END AS NumericPrecisionNumber,
			[eis].NumericScaleNumber,
			COALESCE(IIF( pk.Value IS NULL, NULL, ROW_NUMBER() OVER (PARTITION BY [eis].SourceObjectID ORDER BY pk.Value )), KeySequenceNumber) AS KeySequenceNumber,
			DataTypeName AS OriginalDataTypeName
		FROM [nuuMeta].[SourceInformationSchema] eis
		LEFT JOIN [nuuMeta].SourceObject obj
			ON obj.ID = eis.SourceObjectID
		LEFT JOIN [nuuMetaView].SourceConnectionDefinitions con
			ON con.SourceConnectionName = obj.SourceConnectionName
		OUTER APPLY (
			SELECT Value 
			FROM STRING_SPLIT(obj.PrimaryKeyColumns,',')
			WHERE Value = eis.ColumnName
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
	COALESCE( SourceData.FullDataTypeName, SourceTable.FullDataTypeName ) AS FullDataTypeName,
	COALESCE( SourceData.NullableName, SourceTable.NullableName ) AS NullableName,
	COALESCE( SourceData.DataTypeName, SourceTable.DataTypeName ) AS DataTypeName,
	COALESCE( SourceData.MaximumLenghtNumber, SourceTable.MaximumLenghtNumber ) AS MaximumLenghtNumber,
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