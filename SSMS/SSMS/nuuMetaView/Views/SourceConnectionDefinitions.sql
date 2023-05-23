






CREATE VIEW [nuuMetaView].[SourceConnectionDefinitions]
AS

SELECT
	ID AS SourceConnectionID,
	SourceConnectionName,
	SourceConnectionType,
	CASE SourceConnectionType
		WHEN 'AzureSqlDatabase' THEN 'AzureSqlTable'
		WHEN 'AzureBlobStorage' THEN 'AzureBlobStorageLocation'
		WHEN 'AzureDataLakeStore' THEN 'AzureDataLakeStoreLocation'
		WHEN 'AzureDatabricksDeltaLake' THEN 'AzureDatabricksDeltaLakeDataset'
		WHEN 'AzureBlobFS' THEN 'AzureBlobFSLocation'
		WHEN 'AzureMySql' THEN 'AzureMySqlTable'
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
		WHEN 'NUUDL' THEN 'NuuDatalake'
		ELSE ''
	END AS SourceObjectType,
	IIF( SourceConnectionType IN ('FileServer', 'FtpServer', 'Hdfs', 'Sftp', 'AzureBlobStorage', 'AzureDataLakeStore', 'AzureBlobFS'	), 1, 0 ) AS IsFileObject,
	DestinationSchemaName
FROM nuuMeta.SourceConnection