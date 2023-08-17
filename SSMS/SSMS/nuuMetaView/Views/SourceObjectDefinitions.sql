




CREATE VIEW [nuuMetaView].[SourceObjectDefinitions]
AS
SELECT
	obj.ID AS [SourceObjectID],
	con.ID AS SourceConnectionID,
	con.SourceConnectionName,
	con.SourceConnectionType,
	con.Environment,
	obj.SourceSchemaName,
	obj.SourceObjectName,
	obj.ExtractSQLFilter,
	obj.SourceQuery,
	obj.SourceIsReadyQuery,
	obj.ExtractPattern,
	con.DestinationSchemaName,
	obj.SourceObjectName AS DestinationTableName,
	CASE
		WHEN obj.HistoryType <> 'None' THEN 1
		ELSE 0
	END PreserveHistoryFlag,
	HistoryTrackingColumns,
	obj.NUUDLJobCode,
	vct.DelimitedIdentifier,
	IIF( con.SourceConnectionType IN ('AzureBlobStorage', 'AzureDataLakeStore', 'AzureBlobFS', 'AzureFileStorage'), 'AzureFlatFile', 'Standard' ) AS SourceDatasetPattern,
	obj.SourceConnectionName + '_DynamicDataset' AS SourceDatasetName,
	'Template_Pipeline_Extract_' + con.SourceConnectionType + '_' + obj.ExtractPattern AS TemplateName,
	obj.WatermarkColumnName,
	obj.WatermarkRollingWindowDays,
	obj.WatermarkIsDate,
	obj.WatermarkLastValue,
	obj.WatermarkInQuery,
	'EXT_1_' + con.SourceConnectionName + '_' + obj.SourceObjectName as ADFPipelineName,
	CASE
		WHEN con.SourceConnectionType = 'Oracle' THEN 'OracleSource'
		WHEN con.SourceConnectionType = 'SqlServer' THEN 'SqlSource'
		WHEN con.SourceConnectionType = 'AzureSqlDatabase' THEN 'SqlSource'
		WHEN con.SourceConnectionType = 'MySQL' THEN 'RelationalSource'
		WHEN con.SourceConnectionType = 'Db2' THEN 'OdbcSource'
		WHEN con.SourceConnectionType = 'AzureDatabricksDeltaLake' THEN 'AzureDatabricksDeltaLakeSource'
		--WHEN FileExtension = 'csv' THEN 'DelimitedTextSource'
		--WHEN FileExtension = 'parquet' THEN 'ParquetSource'
		--WHEN FileExtension = 'avro' THEN 'AvroSource'
		--WHEN FileExtension = 'orc' THEN 'OrcSource'
		ELSE ''
	END AS ADFCopySourceType,
	CASE con.SourceConnectionType
		WHEN 'AzureSqlDatabase' THEN 'AzureSqlTable'
		WHEN 'AzureBlobStorage' THEN 'AzureBlobStorageLocation'
		WHEN 'AzureDatabricksDeltaLake' THEN 'AzureDatabricksDeltaLakeDataset'
		WHEN 'AzureDataLakeStore' THEN 'AzureDataLakeStoreLocation'
		WHEN 'AzureBlobFS' THEN 'AzureBlobFSLocation'
		WHEN 'AzureMySql' THEN 'AzureMySqlTable'
		WHEN 'AzureFileStorage' THEN 'AzureFileStorageLocation'
		WHEN 'AzurePostgreSql' THEN 'AzurePostgreSqlTable'
		WHEN 'SqlServer' THEN 'SqlServerTable'
		WHEN 'AzureSqlDW' THEN 'AzureSQLDWDataset'
		WHEN 'AzureSearch' THEN 'AzureSearchIndex'
		WHEN 'AzureTableStorage' THEN 'AzureTable'
		WHEN 'AmazonRedshift' THEN 'RelationalTable'
		WHEN 'Db2' THEN 'RelationalTable'
		WHEN 'Drill' THEN 'DrillTable'
		WHEN 'GoogleBigQuery' THEN 'GoogleBigQueryObject'
		WHEN 'Greenplum' THEN 'GreenplumTable'
		WHEN 'HBase' THEN 'HBaseObject'
		WHEN 'Hive' THEN 'HiveObject'
		WHEN 'Impala' THEN 'ImpalaObject'
		WHEN 'Odbc' THEN 'RelationalTable'
		WHEN 'MariaDB' THEN 'MariaDBTable'
		WHEN 'MySQL' THEN 'RelationalTable'
		WHEN 'Netezza' THEN 'NetezzaTable'
		WHEN 'Oracle' THEN 'OracleTable'
		WHEN 'Phoenix' THEN 'PhoenixObject'
		WHEN 'PostgreSql' THEN 'RelationalTable'
		WHEN 'Presto' THEN 'PrestoObject'
		WHEN 'SapBw' THEN 'RelationalTable'
		WHEN 'SapHana' THEN 'RelationalTable'
		WHEN 'Spark' THEN 'SparkObject'
		WHEN 'Sybase' THEN 'RelationalTable'
		WHEN 'Teradata' THEN 'RelationalTable'
		WHEN 'Vertica' THEN 'VerticaTable'
		WHEN 'Cassandra' THEN 'CassandraTable'
		WHEN 'Couchbase' THEN 'CouchbaseTable'
		WHEN 'MongoDb' THEN 'MongoDbCollection'
		WHEN 'AmazonS3' THEN 'AmazonS3Location'
		WHEN 'FileServer' THEN 'FileServerLocation'
		WHEN 'FtpServer' THEN 'FtpServerLocation'
		WHEN 'Hdfs' THEN 'HdfsLocation'
		WHEN 'Sftp' THEN 'SftpLocation'
		WHEN 'HttpServer' THEN 'HttpServerLocation'
		WHEN 'Odata' THEN 'ODataResource'
		WHEN 'Odbc' THEN 'RelationalTable'
		ELSE ''
	END AS ObjectType,
	CASE con.SourceConnectionType
		WHEN 'AzureSqlDatabase' THEN 'sqlReaderQuery'
		WHEN 'AzureBlobStorage' THEN 'AzureBlob'
		WHEN 'AzureDatabricksDeltaLake' THEN 'query'
		WHEN 'AzureDataLakeStore' THEN 'AzureDataLakeStoreFile'
		WHEN 'AzureBlobFS' THEN 'AzureBlobFSFile'
		WHEN 'AzureMySql' THEN 'query'
		WHEN 'AzurePostgreSql' THEN 'query'
		WHEN 'SqlServer' THEN 'sqlReaderQuery'
		WHEN 'AzureSqlDW' THEN 'sqlReaderQuery'
		WHEN 'AzureSearch' THEN 'AzureSearchIndex'
		WHEN 'AzureTableStorage' THEN 'azureTableSourceQuery'
		WHEN 'AmazonRedshift' THEN 'query'
		WHEN 'Db2' THEN 'query'
		WHEN 'Drill' THEN 'query'
		WHEN 'GoogleBigQuery' THEN 'query'
		WHEN 'Greenplum' THEN 'query'
		WHEN 'HBase' THEN 'query'
		WHEN 'Hive' THEN 'query'
		WHEN 'Impala' THEN 'query'
		WHEN 'Odbc' THEN 'query'
		WHEN 'MariaDB' THEN 'query'
		WHEN 'MySQL' THEN 'query'
		WHEN 'Netezza' THEN 'query'
		WHEN 'Oracle' THEN 'oracleReaderQuery'
		WHEN 'Phoenix' THEN 'query'
		WHEN 'PostgreSql' THEN 'query'
		WHEN 'Presto' THEN 'query'
		WHEN 'SapBw' THEN 'query'
		WHEN 'SapHana' THEN 'query'
		WHEN 'Spark' THEN 'query'
		WHEN 'Sybase' THEN 'query'
		WHEN 'Teradata' THEN 'query'
		WHEN 'Vertica' THEN 'query'
		WHEN 'Cassandra' THEN 'query'
		WHEN 'Couchbase' THEN 'query'
		WHEN 'MongoDb' THEN 'query'
		WHEN 'AmazonS3' THEN 'AmazonS3Object'
		WHEN 'FileServer' THEN 'FileShare'
		WHEN 'FtpServer' THEN 'FileShare'
		WHEN 'Hdfs' THEN 'FileShare'
		WHEN 'Sftp' THEN 'FileShare'
		WHEN 'HttpServer' THEN 'HttpFile'
		WHEN 'Odata' THEN 'query'
		WHEN 'Odbc' THEN 'query'
		ELSE ''
	END AS AzureSQLType
FROM nuuMeta.[SourceObject] AS obj
LEFT JOIN nuuMeta.SourceConnection con
	ON con.SourceConnectionName = obj.SourceConnectionName
LEFT JOIN nuuMeta.ValidConnectionType vct
	ON vct.ConnectionType = con.SourceConnectionType