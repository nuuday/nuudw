 
 Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

[Reflection.Assembly]::LoadWithPartialName("Newtonsoft.Json.dll")
IMPORT-Module sqlserver
IMPORT-Module Az
# =====================
# Set Variables
# =====================

# The destination path of the .json-files
$ADFPath = (Get-Item -Path ".\").FullName + '\';

# The subscription ID for the Azure environment
$AzureSubscriptionID = "155e9e90-807a-43a9-811b-8f7bdb95a801";

# =====================
# Login i Azure
# =====================

#NB!!! Make sure you are logged into the customer tenant in the PS Session. When this is done you do not need to login again in the session.
#Use the cmd below to login

#Login-AzAccount -Tenant 'c95a25de-f20a-4216-bc84-99694442c1b5'

Select-AzSubscription $AzureSubscriptionID

# The connectionstring for the Azure SQL DB
$Secret = Get-AzKeyVaultSecret -VaultName "nuudw-kv01-dev" -Name "ConnectionString-nuudwsqldb01"
$ConnectionString = $Secret.SecretValueText
$ConnectionString = (Get-AzKeyVaultSecret -VaultName "nuudw-kv01-dev" -Name "ConnectionString-nuudwsqldb01").SecretValue | ConvertFrom-SecureString -AsPlainText
# Set working directory (where the .json ADF templates are located)
Set-Location $ADFPath

# =====================
# Datasets
# =====================

# Make View for meta.SourceConnections?
$SourceConnections = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT ID, Name, ConnectionType, 	CASE ConnectionType
				WHEN 'AzureSqlDatabase'		THEN 'AzureSqlTable'
				WHEN 'AzureBlobStorage'		THEN 'AzureBlobStorageLocation'
				WHEN 'AzureDataLakeStore'	THEN 'AzureDataLakeStoreLocation'
				WHEN 'AzureBlobFS'			THEN 'AzureBlobFSLocation'
				WHEN 'AzureMySql'			THEN 'AzureMySqlTable'
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
		IIF(ConnectionType IN (
			'FileServer'
			,'FtpServer'
			,'Hdfs'
			,'Sftp'
			,'AzureBlobStorage'
			,'AzureDataLakeStore'
			,'AzureBlobFS'
		), 1, 0) AS IsFileObject,
        ExtractSchemaName
		FROM meta.SourceConnections WHERE ExcludeFlag = 0"

$TargetConnections = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT DISTINCT TargetConnections.Name, TargetConnections.ConnectionType,'AzureSqlTable' AS ObjectType, SourceConnectionID, SourceConnections.Name AS SourceConnectionName,SourceConnections.ExtractSchemaName FROM meta.TargetConnections INNER JOIN meta.TargetObjects ON TargetObjects.TargetConnectionID = TargetConnections.ID INNER JOIN meta.SourceObjects ON SourceObjects.ID = TargetObjects.SourceObjectID INNER JOIN meta.SourceConnections ON SourceConnections.ID = SourceObjects.SourceConnectionID  WHERE TargetConnections.ConnectionType = 'AzureSqlDatabase' AND TargetConnections.ExcludeFlag = 0"
		
$ADFDatabase = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT VariableVaultName "nuudw-kv01-dev" -Name "ConnectionString-nuudwsqldb01Value, 'AzureSqlTable' AS ObjectType FROM meta.Variables WHERE VariableName = 'DatabaseNameMeta'"

write-host "# ============================="
write-host "# Create Datasets"
write-host "# ============================="
write-host ""
  

foreach ($rec in $ADFDatabase) {

    $DatasetName = ($rec.VariableValue + "_DynamicDataset")
 
     $DatasetExtractInformationSchemaSource = (Get-Content ('Templates\Template_Dataset_Standard.json') ) `
			-replace "<%ADFLinkedServiceName%>",$rec.VariableValue `
			-replace "<%ADFDatasetType%>",$rec.ObjectType `
            -replace "<%ADFFolderName%>","DynamicDatasets" `
            -replace "<%ADFDatasetName%>",($rec.VariableValue + "_DynamicDataset") `
		
    Write-Host "Generating AzureSqlTable dataset"$DatasetName"...." -ForegroundColor Yellow  -NoNewline
    Write-Host "Done"-ForegroundColor Green   

    # Set datasets
    Set-Content -Path ($ADFPath + "dataset\" + $rec.VariableValue + "_DynamicDataset.json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($DatasetExtractInformationSchemaSource).ToString()) -NoNewline
   
    }

foreach ($con in $SourceConnections) {
	if ($con.IsFileObject -eq 0) {

        $SourceDatasetName = ($con.Name + "_DynamicDataset")
	
        $DatasetExtractInformationSchemaSource = (Get-Content ('Templates\Template_Dataset_Standard.json') ) `
			-replace "<%ADFLinkedServiceName%>",$con.Name `
			-replace "<%ADFDatasetType%>",$con.ObjectType `
            -replace "<%ADFFolderName%>","DynamicDatasets" `
            -replace "<%ADFDatasetName%>",$SourceDatasetName `
            
	    Write-Host "Generating"$con.ObjectType"dataset"$SourceDatasetName"...." -ForegroundColor Yellow  -NoNewline
        Write-Host "Done"-ForegroundColor Green  
         
		# Set dynamic datasets
		Set-Content -Path ($ADFPath + "dataset\" + $con.Name + "_DynamicDataset.json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($DatasetExtractInformationSchemaSource).ToString()) -NoNewline
    }
	else   
    {

		$filetypes = @("Orc", "Parquet", "Avro","DelimitedText")
		
        foreach ($filetype in $filetypes) {

            $datasetSettings = ''

            # Set compression codec depending on file type
            if ($filetype -eq 'Avro') 
            { 
                $datasetSettings += ', "avroCompressionCodec": {"value": "@dataset().CompressionCodec","type": "Expression"}' 
            }
            elseif ($filetype -eq 'Parquet' -Or $filetype -eq 'DelimitedText') 
            { 
                $datasetSettings += ', "compressionCodec": {"value": "@dataset().CompressionCodec","type": "Expression"}' 
            }  
            
            if ($filetype -eq 'DelimitedText') {																													
                $datasetSettings += ', "columnDelimiter": { "value": "@dataset().ColumnDelimiter", "type": "Expression" }'
                $datasetSettings += ', "escapeChar": { "value": "@dataset().EscapeCharacter", "type": "Expression" }'
                $datasetSettings += ', "quoteChar": { "value": "@dataset().TextQualifier", "type": "Expression" }'
                $datasetSettings += ', "firstRowAsHeader": { "value": "@dataset().IsHeaderPresent", "type": "Expression" }'
                $datasetSettings += ', "encodingName": { "value": "@dataset().Encoding", "type": "Expression" }'
            }

           
            $dataSetName = $con.Name+"_"+$filetype+"_DynamicDataset"

			$DatasetExtractInformationSchemaSource = (Get-Content ('Templates\Template_Dataset_Flatfile.json') ) `
            -replace "<%ADFLinkedServiceName%>",$con.Name `
            -replace "<%ADFDatasetName%>", $dataSetName `
            -replace "<%ADFFolderName%>","DynamicDatasets" `
            -replace "<%ADFAzureFileTypeName%>",$filetype `
            -replace "<%ADFDatasetType%>",$con.ObjectType `
            -replace "<%ADFDatasetSettings%>",$datasetSettings `

            Write-Host "Generating FlatFile dataset"$dataSetName"...." -ForegroundColor Yellow  -NoNewline
            Write-Host "Done"-ForegroundColor Green    
			
			# Set datasets
			Set-Content -Path ($ADFPath + "dataset\"+ $con.Name+"_"+$filetype+"_DynamicDataset.json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($DatasetExtractInformationSchemaSource).ToString()) -NoNewline
		}
	}

}


foreach ($tar in $TargetConnections) {

     $TargetDatasetName = $tar.Name + "_DynamicDataset"

     $DatasetTarget = (Get-Content ('Templates\Template_Dataset_Standard.json') ) `
        -replace "<%ADFLinkedServiceName%>",$tar.Name `
        -replace "<%ADFFolderName%>","DynamicDatasets" `
        -replace "<%ADFDatasetName%>",$TargetDatasetName `
        -replace "<%ADFDatasetType%>",$tar.ObjectType `

     Write-Host "Generating"$tar.ObjectType"dataset"$TargetDatasetName"...." -ForegroundColor Yellow  -NoNewline
     Write-Host "Done"-ForegroundColor Green   

    # Set datasets
     Set-Content -Path ($ADFPath +"dataset\" + $TargetDatasetName + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse( $DatasetTarget).ToString()) -NoNewline
   
    }

write-host ""
write-host "# ============================="
write-host "# Create Extract Informationschema Pipelines"
write-host "# ============================="
write-host ""

foreach ($row in $SourceConnections) {  

     $PipelineName = "ExtractInformationSchema_" + $row.Name
     
     $DatabaseName = $ADFDatabase.VariableValue

     $TargetSql_pipeline = ""
     $Placeholder = ""

     foreach ($targetrow in $TargetConnections | Where-Object {$_.SourceConnectionID -eq $row.ID}) {

   
     Write-Host "Including:"$targetrow.Name"in"$row.Name -ForegroundColor Yellow   
     $Placeholder = (Get-Content ('Templates\Template_Pipeline_ExtractInformationSchemaTarget' + $targetrow.ConnectionType + '.json')) `
        -replace "<%ADFLinkedServiceName%>",$targetrow.Name `
        -replace "<%ADFSourceLinkedServiceName%>",$targetrow.SourceConnectionName `
        -replace "<%ADFExtractSchemaName%>",$row.ExtractSchemaName `
        -replace "<%ADFConnectionTypeName%>",$targetrow.ConnectionType `
        -replace "<%ADFDatabaseName%>",$DatabaseName `

     $TargetSql_pipeline = $TargetSql_pipeline + $Placeholder
        
    }
    
    #$TargetSql = $TargetSql_pipeline.Replace("<%ADFTargetConnections%>","")

    $template_pipeline = (Get-Content ('Templates\Template_Pipeline_ExtractInformationSchema' + $row.ConnectionType + '.json')) `
        -replace "<%ADFLinkedServiceName%>",$row.Name `
        -replace "<%ADFConnectionTypeName%>",$row.ConnectionType `
        -replace "<%ADFExtractSchemaName%>",$row.ExtractSchemaName `
        -replace "<%ADFDatabaseName%>",$DatabaseName `
        -replace "<%ADFTargetConnections%>",$TargetSql_pipeline `

     Write-Host "Generating pipline" $PipelineName"...." -ForegroundColor Yellow  -NoNewline
     Write-Host "Done"-ForegroundColor Green   
     
     Set-Content -Path ($ADFPath+"pipeline\ExtractInformationSchema_" + $row.Name + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($template_pipeline).ToString()) -NoNewline

}
