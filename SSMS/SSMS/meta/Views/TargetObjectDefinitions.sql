


















CREATE VIEW [meta].[TargetObjectDefinitions] AS

select 
	flaf.SourceObjectID,
	flaf.SourceConnectionID,
	flaf.SourceConnectionName,
	'templates\Template_Pipeline_' + IIF(TargetIsSqlObject = 1,'Extract_','Target_') 
								   + IIF(TargetAppendDataFlag = 1 OR TargetIncrementalFlag = 1,'Incremental_','Full_') 
								   + IIF(TargetDynamicExtensionDefinition <> '' AND TargetIsFileObject = 1 AND TargetAppendDataFlag = 0 AND TargetAzureSqlDWFlag = 0,'Expression_','')
								   + IIF(TargetIsSqlObject = 1 AND TargetPreserveHistoryFlag = 1,'History_','')
								   + IIF(TargetIsSqlObject = 1 AND IIF(((OneKeyColumnFlag = 1 AND KeyColumnIsNumericFlag = 1 AND EnableAutoParallelizationFlag = 1) OR PartitionFlag = 1) AND SourceNavisionFlag = 0 AND SourceFileExtractFlag = 0, 1,0) = 1,'Parallel_','')
								   + IIF(SourceIsSqlObject = 1 AND TargetIsSqlObject = 0,'Standard_','')
								   + IIF(TargetIsSqlObject = 1,'Standard_','')
								   + IIF(SourceIsFileObject = 1 AND TargetIsSqlObject = 0,'FlatFile_','')
								   + IIF(TargetIsFileObject = 1 AND TargetAzureSqlDWFlag = 1 AND TargetAzureFileTypeName <> 'Avro','SQLDW_','') AS TemplateName,
	flaf.SourceSchemaName,
	IIF(flaf.SourceFileExtractFlag = 1,'FlatFile',flaf.SourceExtractPattern) AS SourceExtractPattern,
	SourceIsFileObject,
	(case when SourceNavisionFlag = 1 then NavisionCompany + '$' + SourceObjectName else SourceObjectName end) as SourceObjectName,
    SourceObjectName AS SourceTableName,
	flaf.SourceFileSystem,
	flaf.SourceFileFolder,
	flaf.SourceFileName,
	flaf.SourceFileExtension,
	flaf.TargetExtractPattern,
	--IIF(flaf.TargetFileExtractFlag = 1 OR flaf.SourceFileExtractFlag = 1,'FlatFile',flaf.TargetExtractPattern) AS TargetExtractPattern,
	flaf.TargetObjectID,
	flaf.TargetExtractSQLFilter,
	flaf.TargetExtractSchemaName,
	flaf.TargetConnectionName,
	flaf.TargetConnectionType,
	flaf.TargetSCD2ExtractFlag,
	'Controller_Extract_' + SourceConnectionName + '_' + (CASE WHEN TargetConnectionType in ('Excel','FlatFile') THEN TargetConnectionType ELSE TargetConnectionName END) as ControllerName,
	isnull(StringColumnFilter + 'Flaf', '*,Flaf') as StringColumnFilter,
	(case when StringColumnFilter is null then 1 else ExtractAllColumnsFlag end) as ExtractAllColumnsFlag,
	lower(TargetFolderName) AS TargetFolderName,
	IIF(TargetAzureFileTypeName = 'DelimitedText','csv',lower(TargetAzureFileTypeName)) AS TargetFileExtension,
	TargetDynamicExtensionDefinition,
	lower(TargetFileSystemName) AS TargetFileSystemName,
	TargetAzureFileTypeName,
	TargetAppendDataFlag,
	TargetFileExtractFlag,
	TargetFileExtensionName,
	SourceObjectName + '_Append_' + REPLACE(TargetFolderName, '/', '') + TargetFileExtensionName AS TargetAppendFileName,
	SourceObjectName + '_Dummy_' + REPLACE(TargetFolderName, '/', '') + TargetFileExtensionName AS TargetDummyFileName,
	IIF(ISNULL(TargetDynamicExtensionDefinition,'') = '' OR TargetAppendDataFlag = 1 OR TargetAzureSqlDWFlag = 1,SourceObjectName + TargetFileExtensionName,CONCAT('@concat(''',SourceObjectName,''',''_'',',TargetDynamicExtensionDefinition,',''',TargetFileExtensionName,''')')) AS TargetFileName,
	SourceNavisionFlag,
	SourceRemoveBracketsFlag,
	NavisionCompany,
	SourceObjectName as NavisionTableName,
	SourceExtractSchemaName + '.' + SourceObjectName as SourceExtractTableName,	
	'[' + SourceExtractSchemaName + '].[' + SourceObjectName + ']' as SourceExtractTableNameWithBrackets,
	'Extract' + SourceConnectionName + '_'+ TargetConnectionName + '_' +  IIF(TargetFileExtractFlag = 1, TargetFileSystemName + '_' + REPLACE(TargetFolderName, '/', '') + '_','') + SourceObjectName as ExtractPackageName,
	TargetIncrementalValueColumnDefinition,
	IIF(TargetIncrementalValueColumnDefinitionInExtract = '',TargetIncrementalValueColumnDefinition,TargetIncrementalValueColumnDefinitionInExtract) AS TargetIncrementalValueColumnDefinitionInExtract,
	TargetIncrementalFlag,	
	TargetRollingWindowDays,
	TargetPreserveHistoryFlag,
	IIF((select VariableValue from meta.[Variables] where VariableName = 'ExtractCCIFlag') = 1, N'1', N'0') as ColumnStoreFlag,
    IIF((select VariableValue from meta.[Variables] where VariableName = 'ExtractCCIHistoryFlag') = 1, N'1', N'0') as ColumnStoreHistoryFlag,
	ISNULL(SQLScript,'') AS SQLScript,
	ISNULL(ConnectionSQLScript,'') AS ConnectionSQLScript,
	ISNULL(CreateTableSQLScript,'') AS CreateTableSQLScript,
	ISNULL(DropTableSQLScript,'') AS DropTableSQLScript,
	ISNULL(AzureDWSQLScript,'') AS AzureDWSQLScript,
	ISNULL(PartitionSQLScript,'') AS PartitionSQLScript,
	TargetIsDateFlag,
	TargetAzureSQLDWName,
	ISNULL(SCD2Columns,'''''') AS SCD2Columns,
	IIF(ISNULL(NavisionCompany,'') = '',NULL,LEFT(NavisionCompanies,LEN(NavisionCompanies) -1)) AS NavisionCompanies,
	(case when SourceNavisionFlag = 1 then '[' + SourceSchemaName + '].[' + NavisionCompany + '$' + SourceObjectName + ']' else SourceSchemaName + '.' + SourceObjectName end) AS SourceTable,
    SourceConnectionName + IIF(SourceFileExtractFlag = 1,'_' + IIF(SourceFileExtension = 'csv','DelimitedText',SourceFileExtension),'') + '_DynamicDataset' AS SourceDatasetName,
    TargetConnectionName + IIF(TargetFileExtractFlag = 1,'_' + TargetAzureFileTypeName,'') + '_DynamicDataset' AS TargetDatasetName,
	(SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameMeta') AS DatabaseName,
	CASE 
		WHEN SourceConnectionType = 'Oracle' THEN 'OracleSource'
		WHEN SourceConnectionType = 'SqlServer' THEN 'SqlSource'
		WHEN SourceConnectionType = 'AzureSqlDatabase' THEN 'SqlSource'
		WHEN SourceConnectionType = 'MySQL' THEN 'RelationalSource'
		WHEN SourceFileExtension = 'csv' THEN 'DelimitedTextSource'
		WHEN SourceFileExtension = 'parquet' THEN 'ParquetSource'
		WHEN SourceFileExtension = 'avro' THEN 'AvroSource'
		WHEN SourceFileExtension = 'orc' THEN 'OrcSource'
		ELSE ''
	END AS ADFCopySourceType,
	CASE TargetConnectionType
		WHEN 'SqlServer' THEN 'SqlSink'
		WHEN 'AzureSqlDatabase' THEN 'SqlSink'
		WHEN 'AzureSqlDW' THEN 'SqlDWSink'
		WHEN 'AzureBlobFS' THEN TargetAzureFileTypeName + 'Sink'
		ELSE ''
	END AS ADFCopyTargetType,
	CASE SourceConnectionType
				WHEN 'AzureSqlDatabase'		THEN 'AzureSqlTable'
				WHEN 'AzureBlobStorage'		THEN 'AzureBlobStorageLocation'
				WHEN 'AzureDataLakeStore'	THEN 'AzureDataLakeStoreLocation'
				WHEN 'AzureBlobFS'			THEN 'AzureBlobFSLocation'
				WHEN 'AzureMySql'			THEN 'AzureMySqlTable'
				WHEN 'AzureFileStorage'		THEN 'AzureFileStorageLocation'
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
		END AS SourceObjectType,
	CASE TargetConnectionType
				WHEN 'AzureSqlDatabase'		THEN 'AzureSqlTable'
				WHEN 'AzureBlobFS'			THEN 'AzureBlobFSLocation'
				WHEN 'AzureSqlDW'			THEN 'AzureSQLDWDataset'
				ELSE ''
		END AS TargetObjectType,
	CASE SourceConnectionType
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
		END AS SourceAzureSQLType,
	TargetAzureSqlDWFlag,
	IIF(SourceConnectionType IN ('AzureBlobStorage','AzureDataLakeStore','AzureBlobFS','AzureFileStorage'),'FlatFile','Standard') AS SourceDatasetPattern,
	IIF(TargetConnectionType IN ('AzureBlobStorage','AzureDataLakeStore','AzureBlobFS'),'FlatFile','Standard') AS TargetDatasetPattern,
	IIF(((OneKeyColumnFlag = 1 AND KeyColumnIsNumericFlag = 1 AND EnableAutoParallelizationFlag = 1) OR PartitionFlag = 1) AND SourceNavisionFlag = 0, 1,0) AS ParallelizationFlag,
	PartitionFlag,
	UseModulusFlag,
	PartitionValueColumnDefinition
from 
	(
		select
			TargetObjects.*,
			IIF(SourceConnectionType IN (
			'FileServer'
			,'FtpServer'
			,'Hdfs'
			,'Sftp'
			,'AzureBlobStorage'
			,'AzureDataLakeStore'
			,'AzureBlobFS'
			,'AzureFileStorage'
			), 1, 0) AS SourceIsFileObject,
			IIF(SourceConnectionType IN (
			'AzureSqlDatabase'
			,'SqlServer'
			,'Oracle'
			,'AzureMySql'			
			,'AzurePostgreSql'		
			,'SqlServer'
			,'Db2'					
			), 1, 0) AS SourceIsSqlObject,
		   IIF(TargetConnectionType IN ('AzureBlobStorage' 
				,'AzureDataLakeStore'
				,'AzureBlobFS'),1,0) AS TargetIsFileObject,
		   IIF(TargetConnectionType IN ('AzureSqlDatabase'),1,0) AS TargetIsSqlObject,		
			NavisionCompany.CompanyName AS NavisionCompany,
			NavisionCompany.NavisionCompanies,
			StringColumnFilter = stuff(
				(
					select 
						'' + ltrim(rtrim(ColumnName)) + ',' 
					from 
						meta.SourceColumns
					where 
						SourceObjectID = TargetObjects.SourceObjectID
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
						meta.TargetObjectSCD2Setup
					where 
						TargetObjectID = TargetObjects.TargetObjectID
					for XML PATH(''), TYPE
				).value('.[1]', 'nvarchar(max)'), 
				1, 
				0, 
				''
			),
			(case when AllColumns.SourceObjectID is not null then 1 else 0 end) as ExtractAllColumnsFlag,
			(SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DefaultMaxDop') AS DefaultMaxDop,
			(SELECT VariableValue FROM meta.Variables WHERE VariableName = 'EnableAutoPartitionFlag') AS EnableAutoParallelizationFlag
		
		from 
			(
				select 
					sourceobj.ID AS SourceObjectID,
					sourceobj.SourceConnectionID,
					sourcecon.ConnectionType AS SourceConnectionType,
					sourcecon.Name AS SourceConnectionName,
					sourcecon.ExtractSchemaName AS SourceExtractSchemaName,
					sourceobj.ObjectName AS SourceObjectName,
					sourceobj.SchemaName AS SourceSchemaName,
					sourceobj.ExtractPattern AS SourceExtractPattern,
					sourceobj.ExtractSQLFilter AS SourceExtractFilter,
					sourceobj.FileExtractFlag AS SourceFileExtractFlag,
					sourcecon.NavisionFlag,
					isnull(sourcefilesetup.FileSystem,'') AS SourceFileSystem,
					isnull(sourcefilesetup.Folder,'') AS SourceFileFolder,
					isnull(sourcefilesetup.FileName,'') AS SourceFileName,
					isnull(sourcefilesetup.FileExtension,'') AS SourceFileExtension,
					targetobj.ID AS TargetObjectID,
					targetobj.TargetConnectionID,
					targetobj.ExtractPattern AS TargetExtractPattern,
					targetobj.ExtractSQLFilter AS TargetExtractSQLFilter,
					targetobj.PreserveHistoryFlag AS TargetPreserveHistoryFlag,
					targetobj.IncrementalFlag AS TargetIncrementalFlag,
					targetobj.SCD2ExtractFlag AS TargetSCD2ExtractFlag,
					targetobj.FileTargetFlag AS TargetFileExtractFlag,
					targetobj.AzureSqlDWFlag AS TargetAzureSqlDWFlag,
					targetobj.ControllerExcludeFlag AS TargetControllerExcludeFlag,
					targetfilesetup.FolderName AS TargetFolderName,
					targetfilesetup.FileSystemName AS TargetFileSystemName,
					targetfilesetup.FileDynamicExtensionDefinition AS TargetDynamicExtensionDefinition,					
					targetfilesetup.AzureFileTypeName AS TargetAzureFileTypeName,
					CASE targetfilesetup.AzureFileTypeName
						WHEN 'DelimitedText' THEN '.csv'
						WHEN 'Parquet'		 THEN '.parquet'
						WHEN 'Json'			 THEN '.json'
						WHEN 'Avro'			 THEN '.avro'
						WHEN 'Orc'			 THEN '.orc'
						ELSE ''
					END	AS TargetFileExtensionName,
					targetfilesetup.AppendDataFlag AS TargetAppendDataFlag,
					IIF(targetobj.AzureSqlDWFlag = 1, 'extadl' + lower(targetfilesetup.FileSystemName) + lower(replace(targetfilesetup.FolderName,'/','_')),sourcecon.ExtractSchemaName) AS TargetExtractSchemaName,
					targetcon.[Name] AS TargetConnectionName,
					targetcon.ConnectionType AS TargetConnectionType,
					ISNULL(sourcecon.NavisionFlag,0) AS SourceNavisionFlag,
					targetincrementalsetup.IncrementalValueColumnDefinition AS TargetIncrementalValueColumnDefinition,
					targetincrementalsetup.IncrementalValueColumnDefinitionInExtract AS TargetIncrementalValueColumnDefinitionInExtract,
					targetincrementalsetup.IsDateFlag AS TargetIsDateFlag,			
					targetincrementalsetup.RollingWindowDays AS TargetRollingWindowDays,					
					ISNULL(sourcecon.RemoveBracketsFlag,0) AS SourceRemoveBracketsFlag,
					biml.SQLScript,
					biml.ConnectionSQLScript,
					biml.CreateTableSQLScript,
					biml.DropTableSQLScript,
					biml.AzureDWSQLScript,
					SourceBiml.PartitionSQLScript,
					sourceobj.PartitionFlag,
					AzureSqlDW.Name AS TargetAzureSqlDWName,
					ISNULL((SELECT TOP 1 UseModulusFlag FROM meta.SourceObjectPartition WHERE SourceObjectPartition.SourceObjectID = targetobj.SourceObjectID ORDER BY UseModulusFlag DESC),0) AS UseModulusFlag,
					(SELECT TOP 1 PartitionValueColumnDefinition FROM meta.SourceObjectPartition WHERE SourceObjectPartition.SourceObjectID = targetobj.SourceObjectID ORDER BY UseModulusFlag DESC) AS PartitionValueColumnDefinition,
					IIF((SELECT SUM(KeySequenceNumber) AS KeySequenceNumber FROM meta.ExtractInformationSchemaDefinitions WHERE KeySequenceNumber = 1 AND SourceObjectID = sourceobj.ID AND ColumnName NOT IN ('DWNavisionCompany')) = 1,1,0) AS OneKeyColumnFlag,
					IIF((SELECT DataTypeName FROM meta.ExtractInformationSchemaDefinitions WHERE KeySequenceNumber = 1 AND SourceObjectID = sourceobj.ID) in ('int','tinyint','decimal','numeric'),1,0) AS KeyColumnIsNumericFlag

					
				from 
					meta.[SourceObjects] as sourceobj inner join
					meta.TargetObjects as targetobj on
						targetobj.SourceObjectID = sourceobj.ID left join
					meta.SourceObjectFileSetup as sourcefilesetup on
						sourceobj.ID = sourcefilesetup.SourceObjectID left join 
					meta.[TargetObjectFileSetup] as targetfilesetup on 
						targetobj.ID = targetfilesetup.TargetObjectID left join
					meta.[SourceObjectIncrementalSetup] as targetincrementalsetup on 
						targetobj.SourceObjectID = targetincrementalsetup.SourceObjectID join
					meta.TargetConnections as targetcon on 
						targetobj.TargetConnectionID = targetcon.ID inner join
					meta.SourceConnections as sourcecon on
						sourcecon.ID = sourceobj.SourceConnectionID left join
					meta.FrameworkMetaData as Biml on
						biml.TargetObjectID = targetobj.ID left join		
					meta.FrameworkMetaData as SourceBiml on
						SourceBiml.SourceObjectID = targetobj.SourceObjectID left join
					meta.TargetAzureSQLDWSetup as AzureSqlDWSetup on
						targetobj.ID = AzureSqlDWSetup.TargetObjectID left join
					meta.TargetConnections as AzureSqlDW on
						AzureSqlDW.ID = AzureSqlDWSetup.TargetConnectionID 				
				where
					targetobj.ExcludeFlag = 0 and
					targetcon.ExcludeFlag = 0 -- and
					--obj.ID = (select distinct SourceObjectID from etl.SourceColumns where SourceObjectID = obj.ID) /* Exclude items that have not been entered in SourceColumns */

			) as TargetObjects left join

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
				TargetObjects.SourceObjectID = AllColumns.SourceObjectID left join

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
				TargetObjects.SourceConnectionID = NavisionCompany.SourceConnectionID and
				TargetObjects.SourceNavisionFlag = 1 and 
				NavisionCompany.rnk = 1 



	) as flaf