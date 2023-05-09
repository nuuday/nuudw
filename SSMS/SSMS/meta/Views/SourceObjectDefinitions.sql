














CREATE VIEW [meta].[SourceObjectDefinitions] AS

select 
	SourceObjectID,
	SourceConnectionID,
	flaf.SchemaName,
	'templates\Template_Pipeline_Extract_' + IIF(IncrementalFlag = 1,'Incremental_','Full_') 
										   + IIF(PreserveHistoryFlag = 1,'History_','')
										   + IIF(((OneKeyColumnFlag = 1 AND KeyColumnIsNumericFlag = 1 AND EnableAutoParallelizationFlag = 1) OR PartitionFlag = 1) AND NavisionFlag = 0 AND FileExtractFlag = 0,'Parallel_','')
										   + 'Standard_' AS TemplateName,
	(case when NavisionFlag = 1 then NavisionCompany + '$' + ObjectName else ObjectName end) as ObjectName,
	ObjectName as Name,
	flaf.ExtractPattern,
	flaf.ExtractSQLFilter,
	flaf.KeyColumnFlag,
	flaf.InitialCatalog,
	flaf.ConnectionString,
	flaf.ExtractSchemaName,
	flaf.ConnectionName,
	flaf.ConnectionType,
    SourceIsFileObject, 
	IIF(ConnectionType IN ('AzureBlobStorage','AzureDataLakeStore','AzureBlobFS','AzureFileStorage'
	),'FlatFile','Standard') AS SourceDatasetPattern,
	'Controller_Extract' + (case when flaf.ConnectionType IN ('Excel','FlatFile') then flaf.ConnectionType else flaf.ConnectionName end) as ControllerName,
	isnull(StringColumnFilter + 'Flaf', '*,Flaf') as StringColumnFilter,
	(case when StringColumnFilter is null then 1 else ExtractAllColumnsFlag end) as ExtractAllColumnsFlag,
	LoopFileFlag as LoopFile,
	FileSystem,
	FileName,
	Folder,
	FileExtension,
	FileSpecification,
	FileName + '.' + FileExtension AS FullFileName,
	RowSeparator,
	ColumnDelimiter,
	ISNULL(TextQualifier,'') AS TextQualifier,
	IsHeaderPresent,
	Encoding,
	PreserveHistoryFlag,
	DataSource,
	NavisionFlag,
	RemoveBracketsFlag,
	NavisionCompany,
	ObjectName as NavisionTableName,
	ExtractSchemaName + '.' + ObjectName as ExtractTableName,	
	'[' + ExtractSchemaName + '].[' + ObjectName + ']' as ExtractTableNameWithBrackets,
	'Extract' + ExtractSchemaName + '_' + ObjectName as ExtractPackageName,
	IncrementalValueColumnDefinition,
	IIF(IncrementalValueColumnDefinitionInExtract = '',IncrementalValueColumnDefinition,IncrementalValueColumnDefinitionInExtract) AS IncrementalValueColumnDefinitionInExtract,
	IncrementalFlag,	
	iif((Select compatibility_level from sys.databases where name COLLATE DANISH_NORWEGIAN_CI_AS = (select VariableValue from meta.[Variables] where VariableName = 'DatabaseNameExtract')) > 120
		AND (select VariableValue from meta.[Variables] where VariableName = 'ExtractCCIFlag') = 1, N'1', N'0') as ColumnStoreFlag,
	iif((Select compatibility_level from sys.databases where name  COLLATE DANISH_NORWEGIAN_CI_AS = (select VariableValue from meta.[Variables] where VariableName = 'DatabaseNameExtract')) > 120
		AND (select VariableValue from meta.[Variables] where VariableName = 'ExtractCCIHistoryFlag') = 1, N'1', N'0') as ColumnStoreHistoryFlag,
	SQLScript,
	PartitionSQLScript,
	IsDateFlag,
	RollingWindowDays,
	FileExtractFlag,
	ISNULL(SCD2Columns,'''''') AS SCD2Columns,
	IIF(ISNULL(NavisionCompany,'') = '',NULL,LEFT(NavisionCompanies,LEN(NavisionCompanies) -1)) AS NavisionCompanies,
    (case when NavisionFlag = 1 then '[' + SchemaName + '].[' + NavisionCompany + '$' + ObjectName + ']' else SchemaName + '.' + ObjectName end) AS SourceTable,
	ConnectionName + IIF(FileExtractFlag = 1,'_' + CASE FileExtension 
														WHEN 'csv' THEN 'DelimitedText'
														WHEN 'orc' THEN 'Orc'
														WHEN 'avro' THEN 'Avro'
														WHEN 'parquet' THEN 'Parquet'
												   END ,'') + '_DynamicDataset' AS SourceDatasetName,
    (SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameMeta') + '_DynamicDataset' AS DestinationDatasetName,
	(SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameMeta') AS DatabaseName,
	CASE 
		WHEN ConnectionType = 'Oracle' THEN 'OracleSource'
		WHEN ConnectionType = 'SqlServer' THEN 'SqlSource'
		WHEN ConnectionType = 'AzureSqlDatabase' THEN 'SqlSource'
		WHEN ConnectionType = 'MySQL' THEN 'RelationalSource'
		WHEN FileExtension = 'csv' THEN 'DelimitedTextSource'
		WHEN FileExtension = 'parquet' THEN 'ParquetSource'
		WHEN FileExtension = 'avro' THEN 'AvroSource'
		WHEN FileExtension = 'orc' THEN 'OrcSource'
		ELSE ''
	END AS ADFCopySourceType,
	CASE ConnectionType
				WHEN 'AzureSqlDatabase'		THEN 'AzureSqlTable'
				WHEN 'AzureBlobStorage'		THEN 'AzureBlobStorageLocation'
				WHEN 'AzureDataLakeStore'	THEN 'AzureDataLakeStoreLocation'
				WHEN 'AzureBlobFS'			THEN 'AzureBlobFSLocation'
				WHEN 'AzureMySql'			THEN 'AzureMySqlTable'
				WHEN 'AzureFileStorage'     THEN 'AzureFileStorageLocation'
				WHEN 'AzurePostgreSql'		THEN 'AzurePostgreSqlTable'
				WHEN 'SqlServer'			THEN 'SqlServerTable'
				WHEN 'AzureSqlDW'			THEN 'AzureSQLDWDataset'
				WHEN 'AzureSearch'			THEN 'AzureSearchIndex'
				WHEN 'AzureTableStorage'	THEN 'AzureTable'
				WHEN 'AmazonRedshift'		THEN 'RelationalTable'
				WHEN 'Db2'					THEN 'RelationalTable'
				WHEN 'Drill'				THEN 'DrillTable'
				WHEN 'GoogleBigQuery'		THEN 'GoogleBigQueryObject'
				WHEN 'Greenplum'			THEN 'GreenplumTable'
				WHEN 'HBase'				THEN 'HBaseObject'
				WHEN 'Hive'					THEN 'HiveObject'
				WHEN 'Impala'				THEN 'ImpalaObject'
				WHEN 'Odbc'					THEN 'RelationalTable'
				WHEN 'MariaDB'				THEN 'MariaDBTable'
				WHEN 'MySQL'				THEN 'RelationalTable'
				WHEN 'Netezza'				THEN 'NetezzaTable'
				WHEN 'Oracle'				THEN 'OracleTable'
				WHEN 'Phoenix'				THEN 'PhoenixObject'
				WHEN 'PostgreSql'			THEN 'RelationalTable'
				WHEN 'Presto'				THEN 'PrestoObject'
				WHEN 'SapBw'				THEN 'RelationalTable'
				WHEN 'SapHana'				THEN 'RelationalTable'
				WHEN 'Spark'				THEN 'SparkObject'
				WHEN 'Sybase'				THEN 'RelationalTable'
				WHEN 'Teradata'				THEN 'RelationalTable'
				WHEN 'Vertica'				THEN 'VerticaTable'
				WHEN 'Cassandra'			THEN 'CassandraTable'
				WHEN 'Couchbase'			THEN 'CouchbaseTable'
				WHEN 'MongoDb'				THEN 'MongoDbCollection'
				WHEN 'AmazonS3'				THEN 'AmazonS3Location'
				WHEN 'FileServer'			THEN 'FileServerLocation'
				WHEN 'FtpServer'			THEN 'FtpServerLocation'
				WHEN 'Hdfs'					THEN 'HdfsLocation'
				WHEN 'Sftp'					THEN 'SftpLocation'
				WHEN 'HttpServer'			THEN 'HttpServerLocation'
				WHEN 'Odata'				THEN 'ODataResource'
				WHEN 'Odbc'					THEN 'RelationalTable'
				ELSE ''
		END AS ObjectType,
	CASE ConnectionType
				WHEN 'AzureSqlDatabase'		THEN 'sqlReaderQuery'
				WHEN 'AzureBlobStorage'		THEN 'AzureBlob'
				WHEN 'AzureDataLakeStore'	THEN 'AzureDataLakeStoreFile'
				WHEN 'AzureBlobFS'			THEN 'AzureBlobFSFile'
				WHEN 'AzureMySql'			THEN 'query'
				WHEN 'AzurePostgreSql'		THEN 'query'
				WHEN 'SqlServer'			THEN 'sqlReaderQuery'
				WHEN 'AzureSqlDW'			THEN 'sqlReaderQuery'
				WHEN 'AzureSearch'			THEN 'AzureSearchIndex'
				WHEN 'AzureTableStorage'	THEN 'azureTableSourceQuery'
				WHEN 'AmazonRedshift'		THEN 'query'
				WHEN 'Db2'					THEN 'query'
				WHEN 'Drill'				THEN 'query'
				WHEN 'GoogleBigQuery'		THEN 'query'
				WHEN 'Greenplum'			THEN 'query'
				WHEN 'HBase'				THEN 'query'
				WHEN 'Hive'					THEN 'query'
				WHEN 'Impala'				THEN 'query'
				WHEN 'Odbc'					THEN 'query'
				WHEN 'MariaDB'				THEN 'query'
				WHEN 'MySQL'				THEN 'query'
				WHEN 'Netezza'				THEN 'query'
				WHEN 'Oracle'				THEN 'oracleReaderQuery'
				WHEN 'Phoenix'				THEN 'query'
				WHEN 'PostgreSql'			THEN 'query'
				WHEN 'Presto'				THEN 'query'
				WHEN 'SapBw'				THEN 'query'
				WHEN 'SapHana'				THEN 'query'
				WHEN 'Spark'				THEN 'query'
				WHEN 'Sybase'				THEN 'query'
				WHEN 'Teradata'				THEN 'query'
				WHEN 'Vertica'				THEN 'query'
				WHEN 'Cassandra'			THEN 'query'
				WHEN 'Couchbase'			THEN 'query'
				WHEN 'MongoDb'				THEN 'query'
				WHEN 'AmazonS3'				THEN 'AmazonS3Object'
				WHEN 'FileServer'			THEN 'FileShare'
				WHEN 'FtpServer'			THEN 'FileShare'
				WHEN 'Hdfs'					THEN 'FileShare'
				WHEN 'Sftp'					THEN 'FileShare'
				WHEN 'HttpServer'			THEN 'HttpFile'
				WHEN 'Odata'				THEN 'query'
				WHEN 'Odbc'					THEN 'query'
				ELSE ''
		END AS AzureSQLType,
	TruncateBeforeDeployFlag,
	IIF(((OneKeyColumnFlag = 1 AND KeyColumnIsNumericFlag = 1 AND EnableAutoParallelizationFlag = 1) OR PartitionFlag = 1) AND NavisionFlag = 0, 1,0) AS ParallelizationFlag,
	PartitionFlag,
	UseModulusFlag,
	PartitionValueColumnDefinition,
	DWDestinationFlag,
	TargetDestinationFlag
from 
	(
		select
			ID as SourceObjectID,
			SchemaName, 
			ObjectName, 
			ExtractPattern,
			IIF(ConnectionType IN (
			'FileServer'
			,'FtpServer'
			,'Hdfs'
			,'Sftp'
			,'AzureBlobStorage'
			,'AzureDataLakeStore'
			,'AzureBlobFS'
			,'AzureFileStorage'
			), 1, 0) AS SourceIsFileObject,
			IIF(ConnectionType IN (
			'AzureSqlDatabase'
			,'SqlServer'
			,'Oracle'
			,'AzureMySql'			
			,'AzurePostgreSql'		
			,'SqlServer'
			,'Db2'					
			), 1, 0) AS SourceIsSqlObject,
			InitialCatalog,
			ConnectionString,
			ExtractSchemaName,
			DWDestinationFlag,
			TargetDestinationFlag,
			KeyColumnFlag,
			FileExtractFlag,
			ConnectionName,
			ConnectionType,
			ExtractSQLFilter,
			LoopFileFlag,
			FileSystem,
			Folder,
			FileName,
			FileExtension,
			FileSpecification,
			RowSeparator,
			ColumnDelimiter,
			TextQualifier,
			IsHeaderPresent,	
			Encoding,
			PreserveHistoryFlag,
			DataSource,
			StringColumnFilter = stuff(
				(
					select 
						'' + ltrim(rtrim(ColumnName)) + ',' 
					from 
						meta.SourceColumns
					where 
						SourceObjectID = SourceObjects.ID
					for XML PATH(''), TYPE
				).value('.[1]', 'nvarchar(max)'), 
				1, 
				0, 
				''
			),
			SCD2Columns = stuff(
				(
					select 
						'' + ltrim(rtrim(SCD2ColumnName)) + ',' 
					from 
						meta.SourceObjectSCD2Setup
					where 
						SourceObjectID = SourceObjects.ID
					for XML PATH(''), TYPE
				).value('.[1]', 'nvarchar(max)'), 
				1, 
				0, 
				''
			),
			(case when AllColumns.SourceObjectID is not null then 1 else 0 end) as ExtractAllColumnsFlag,
			isnull(NavisionFlag, 0) as NavisionFlag,
			isnull(RemoveBracketsFlag, 0) as RemoveBracketsFlag,
			isnull(CompanyName, '') as NavisionCompany,
			isnull(IncrementalValueColumnDefinition, '') as IncrementalValueColumnDefinition,
			isnull(IncrementalValueColumnDefinitionInExtract, '') as IncrementalValueColumnDefinitionInExtract,
			RollingWindowDays,
			isnull(IncrementalFlag, 0) as IncrementalFlag,
			SQLScript,
			PartitionSQLScript,
			IsDateFlag,
			NavisionCompanies,
			SourceObjects.SourceConnectionID,
			TruncateBeforeDeployFlag,
			OneKeyColumnFlag,
			KeyColumnIsNumericFlag,
			PartitionFlag,
			ISNULL(UseModulusFlag,0) AS UseModulusFlag,
			PartitionValueColumnDefinition,
			(SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DefaultMaxDop') AS DefaultMaxDop,
			(SELECT VariableValue FROM meta.Variables WHERE VariableName = 'EnableAutoPartitionFlag') AS EnableAutoParallelizationFlag
		from 
			(
				select 
					obj.ID,
					obj.SourceConnectionID,
					obj.ObjectName,
					obj.SchemaName,
					obj.ExtractPattern,
					obj.ExtractSQLFilter,
					obj.DWDestinationFlag,
					obj.TargetDestinationFlag,
					obj.KeyColumnFlag,
					obj.FileExtractFlag,
					file_setup.LoopFileFlag,
					file_setup.FileSystem,
					file_setup.Folder,
					file_setup.FileName,
					file_setup.FileExtension,
					file_setup.FileSpecification,
					file_setup.RowSeparator,
					file_setup.ColumnDelimiter,
					file_setup.TextQualifier,
					file_setup.IsHeaderPresent,	
					file_setup.Encoding,	
					obj.PreserveHistoryFlag,
					con.InitialCatalog,
					con.ConnectionString,
					con.ExtractSchemaName,
					con.[Name] as ConnectionName,
					con.ConnectionType,
					con.DataSource,
					con.NavisionFlag,
					incremental_setup.IncrementalValueColumnDefinition,
					incremental_setup.IncrementalValueColumnDefinitionInExtract,
					incremental_setup.RollingWindowDays,
					obj.IncrementalFlag,
					con.RemoveBracketsFlag,
					biml.SQLScript,
					biml.PartitionSQLScript,
					incremental_setup.IsDateFlag,
					obj.TruncateBeforeDeployFlag,
					obj.PartitionFlag,
					(SELECT TOP 1 UseModulusFlag FROM meta.SourceObjectPartition WHERE SourceObjectPartition.SourceObjectID = obj.ID ORDER BY UseModulusFlag DESC) AS UseModulusFlag,
					(SELECT TOP 1 PartitionValueColumnDefinition FROM meta.SourceObjectPartition WHERE SourceObjectPartition.SourceObjectID = obj.ID ORDER BY UseModulusFlag DESC) AS PartitionValueColumnDefinition,
					IIF((SELECT SUM(KEY_COLUMN_USAGE.ORDINAL_POSITION) AS KeySequenceNumber FROM INFORMATION_SCHEMA.COLUMNS INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS ON TABLE_CONSTRAINTS.TABLE_CATALOG = COLUMNS.TABLE_CATALOG  AND TABLE_CONSTRAINTS.TABLE_SCHEMA = COLUMNS.TABLE_SCHEMA	AND TABLE_CONSTRAINTS.TABLE_NAME = COLUMNS.TABLE_NAME AND TABLE_CONSTRAINTS.CONSTRAINT_TYPE = 'PRIMARY KEY' INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ON KEY_COLUMN_USAGE.CONSTRAINT_NAME = TABLE_CONSTRAINTS.CONSTRAINT_NAME AND KEY_COLUMN_USAGE.COLUMN_NAME = COLUMNS.COLUMN_NAME AND KEY_COLUMN_USAGE.TABLE_SCHEMA = COLUMNS.TABLE_SCHEMA WHERE COLUMNS.TABLE_SCHEMA  COLLATE DANISH_NORWEGIAN_CI_AS = con.ExtractSchemaName AND COLUMNS.TABLE_NAME  COLLATE DANISH_NORWEGIAN_CI_AS = obj.[ObjectName] AND TABLE_CONSTRAINTS.CONSTRAINT_TYPE = 'PRIMARY KEY' AND COLUMNS.COLUMN_NAME NOT IN ('DWNavisionCompany')) = 1,1,0) AS OneKeyColumnFlag,
					IIF((SELECT COLUMNS.[DATA_TYPE] FROM INFORMATION_SCHEMA.COLUMNS INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS ON TABLE_CONSTRAINTS.TABLE_CATALOG = COLUMNS.TABLE_CATALOG  AND TABLE_CONSTRAINTS.TABLE_SCHEMA = COLUMNS.TABLE_SCHEMA	AND TABLE_CONSTRAINTS.TABLE_NAME = COLUMNS.TABLE_NAME AND TABLE_CONSTRAINTS.CONSTRAINT_TYPE = 'PRIMARY KEY' INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ON KEY_COLUMN_USAGE.CONSTRAINT_NAME = TABLE_CONSTRAINTS.CONSTRAINT_NAME AND KEY_COLUMN_USAGE.COLUMN_NAME = COLUMNS.COLUMN_NAME AND KEY_COLUMN_USAGE.TABLE_SCHEMA = COLUMNS.TABLE_SCHEMA WHERE COLUMNS.TABLE_SCHEMA  COLLATE DANISH_NORWEGIAN_CI_AS = con.ExtractSchemaName AND COLUMNS.TABLE_NAME  COLLATE DANISH_NORWEGIAN_CI_AS = obj.[ObjectName] AND TABLE_CONSTRAINTS.CONSTRAINT_TYPE = 'PRIMARY KEY' AND KEY_COLUMN_USAGE.ORDINAL_POSITION = 1) in ('int','tinyint','decimal','numeric'),1,0) AS KeyColumnIsNumericFlag

				from 
					meta.[SourceObjects] as obj left join
					meta.[SourceObjectFileSetup] as file_setup on 
						obj.ID = file_setup.SourceObjectID left join
					meta.[SourceObjectIncrementalSetup] as incremental_setup on 
						obj.ID = incremental_setup.SourceObjectID join
					meta.SourceConnections as con on 
						obj.SourceConnectionID = con.ID left join
					meta.FrameworkMetaData as Biml on
						biml.SourceObjectID = obj.ID
						
				where
					obj.ExcludeFlag = 0 and
					con.ExcludeFlag = 0 -- and
					--obj.ID = (select distinct SourceObjectID from etl.SourceColumns where SourceObjectID = obj.ID) /* Exclude items that have not been entered in SourceColumns */

			) as SourceObjects left join

			-- Source objects where all columns are wanted - *
			(
				select 
					distinct 
					SourceObjectID
				from 
					meta.SourceColumns as col
				where
					[ColumnName] = '*'
			) as AllColumns on 
				SourceObjects.ID = AllColumns.SourceObjectID left join

			-- If any Navision tables present
			(
				select 
					SourceConnectionID,
					CompanyName, 
					row_number() over (partition by SourceConnectionID order by SourceConnectionNavisionSetup.ID asc) as rnk,
					NavisionCompanies = stuff(
										(
											select 
												'' + ltrim(rtrim(CompanyName)) + ','  
											from 
												meta.SourceConnectionNavisionSetup scn 
											inner join 
												meta.SourceConnections sc 
													on scn.SourceConnectionID = sc.ID 
											where 
												ExtractFlag = 1 
												and sc.Name = SourceConnections.Name
											for XML PATH(''), TYPE
										).value('.[1]', 'nvarchar(max)'), 
										1, 
										0, 
										''
									   )
				from 
					meta.SourceConnectionNavisionSetup
				inner join
					meta.SourceConnections
						ON SourceConnections.ID = SourceConnectionNavisionSetup.SourceConnectionID
				where
					ExtractFlag = 1
			) as NavisionCompany on 
				SourceObjects.SourceConnectionID = NavisionCompany.SourceConnectionID and
				SourceObjects.NavisionFlag = 1 and 
				NavisionCompany.rnk = 1

	) as flaf