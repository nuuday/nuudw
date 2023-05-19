 
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

# Set working directory (where the .json ADF templates are located)
Set-Location $ADFPath

# =====================
# Datasets
# =====================
$SourceObject = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT DISTINCT SourceObjectID FROM meta.SourceObjectDefinitions"

write-host ""
write-host "============================="
write-host "Updating Meta Tables"
write-host "============================="
write-host "" 
write-host ""
write-host "Updating Meta Tables..." -NoNewline
$SQL = ""

foreach ($rec in $SourceObject) {
 $PlaceholderSQL = "EXECUTE [meta].[MaintainExtractCreateSourceScript] @SourceObjectID = '" + $rec.SourceObjectID + "',@PrintSQL = 0
 "
 $SQL = $SQL + $PlaceholderSQL
 $PlaceholderSQL = ""

}

if ($SQL.Length -eq 0) {
    write-host "No source objects enabled in meta.SourceObjects" -ForegroundColor Red
    } else {
    Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $SQL

    Write-Host "Done"-ForegroundColor Green
    }

$SourceObjectDefinitions = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT DISTINCT SourceObjectDefinitions.* FROM meta.SourceObjectDefinitions INNER JOIN meta.ExtractInformationSchema ON ExtractInformationSchema.SourceObjectID = SourceObjectDefinitions.SourceObjectID" -MaxCharLength 12000
$ADFDatabase = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT VariableValue, 'AzureSqlTable' AS ObjectType FROM meta.Variables WHERE VariableName = 'DatabaseNameMeta'"
$SourceConnections = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT DISTINCT  [ConnectionName],[ObjectType],[SourceDatasetPattern],[SourceDatasetName], [SourceIsFileObject] FROM [meta].[SourceObjectDefinitions]"




write-host ""
write-host "============================="
write-host "Creating Datasets"
write-host "============================="
write-host ""



foreach ($rec in $ADFDatabase) {

    $DatasetName = ($rec.VariableValue + "_DynamicDataset")

    $DatasetExtractInformationSchemaSource = (Get-Content ('Templates\Template_Dataset_Standard.json') ) `
			-replace "<%ADFLinkedServiceName%>",$rec.VariableValue `
			-replace "<%ADFDatasetType%>",$rec.ObjectType `
            -replace "<%ADFFolderName%>","DynamicDatasets" `
            -replace "<%ADFDatasetName%>",$DatasetName `

    Write-Host "Generating AzureSqlTable dataset"$DatasetName"...." -ForegroundColor Yellow  -NoNewline
    Write-Host "Done"-ForegroundColor Green   

    # Set datasets
    Set-Content -Path ($ADFPath + "dataset\" + $rec.VariableValue + "_DynamicDataset.json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($DatasetExtractInformationSchemaSource).ToString()) -NoNewline
    }



# Create source and extract datasets
foreach ($con in $SourceConnections) {
	if ($con.SourceIsFileObject -eq 0) {
        
        $SourceDatasetName = ($con.ConnectionName + "_DynamicDataset")

        $SourceDataset = (Get-Content ('Templates\Template_Dataset_Standard.json') ) `
			-replace "<%ADFLinkedServiceName%>",$con.ConnectionName `
			-replace "<%ADFDatasetType%>",$con.ObjectType `
            -replace "<%ADFFolderName%>","DynamicDatasets" `
            -replace "<%ADFDatasetName%>",$SourceDatasetName `
                   
        Write-Host "Generating"$con.ObjectType"dataset"$SourceDatasetName"...." -ForegroundColor Yellow  -NoNewline
        Write-Host "Done"-ForegroundColor Green   

		# Set dynamic datasets
		Set-Content -Path ($ADFPath + "dataset\" + $con.ConnectionName + "_DynamicDataset.json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($SourceDataset).ToString()) -NoNewline
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

           
            $dataSetName = $con.ConnectionName+"_"+$filetype+"_DynamicDataset"

			$DatasetExtractInformationSchemaSource = (Get-Content ('Templates\Template_Dataset_Flatfile.json') ) `
            -replace "<%ADFLinkedServiceName%>",$con.ConnectionName `
            -replace "<%ADFDatasetName%>", $dataSetName `
            -replace "<%ADFFolderName%>","DynamicDatasets" `
            -replace "<%ADFAzureFileTypeName%>",$filetype `
            -replace "<%ADFDatasetType%>",$con.ObjectType `
            -replace "<%ADFDatasetSettings%>",$datasetSettings `


			Write-Host "Generating FlatFile dataset"$dataSetName"...." -ForegroundColor Yellow  -NoNewline
            Write-Host "Done"-ForegroundColor Green    

			# Set datasets
			Set-Content -Path ($ADFPath + "dataset\"+ $dataSetName +".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($DatasetExtractInformationSchemaSource).ToString()) -NoNewline
		}
	}

}    

write-host ""
write-host "============================="
write-host "Create Extract Pipelines"
write-host "============================="
write-host ""

foreach ($rec in $SourceObjectDefinitions) {

    $ADFCopySourceType = $rec.ADFCopySourceType
    $ADFSourceQueryProperty = $rec.ADFCopySourceType
    $ADFFolderName = "Extract/Extract_" + $rec.ConnectionName  
    

    $ExtractTemplate = ($rec.TemplateName + $rec.ExtractPattern)   
    $ExtractTemplate += ".json"  
     

            # Debug write
    Write-Host ("Using template: "+$ExtractTemplate) -ForegroundColor Green
     

    $template_pipeline = (Get-Content ($ExtractTemplate)) `
        -replace "<%ADFPipelineName%>",$rec.ExtractPackageName `
        -replace "<%ADFSourceDatasetName%>",$rec.SourceDatasetName `
        -replace "<%ADFExtractSchemaName%>",$rec.ExtractSchemaName `
        -replace "<%ADFObjectName%>",$rec.ObjectName `
        -replace "<%ADFSourceTable%>",$rec.SourceTable `
        -replace "<%ADFTargetTable%>",$rec.ExtractTableName `
        -replace "<%ADFTableName%>",$rec.Name `
        -replace "<%ADFDestinationDatasetName%>", $rec.DestinationDatasetName `
        -replace "<%ADFCopySourceType%>",$ADFCopySourceType `
        -replace "<%ADFDestinationLinkedService%>",$rec.DatabaseName `
        -replace "<%ADFFolderName%>",$ADFFolderName `
        -replace "<%ADFConnectionName%>",$rec.ConnectionName `
        -replace "<%ADFSourceFileSystem%>",$rec.FileSystem `
        -replace "<%ADFSourceFileFolder%>",$rec.Folder `
        -replace "<%ADFSourceFileName%>",$rec.FullFileName `
        -replace "<%ADFSourceFileColumnDelimiter%>",$rec.columnDelimiter `
        -replace "<%ADFSourceFileTextQualifier%>",$rec.TextQualifier.Replace('"','\"') `
        -replace "<%ADFSourceFileIsHeaderPresent%>",$rec.IsHeaderPresent `
		-replace "<%ADFSourceFileEncoding%>",$rec.Encoding `
        -replace "<%ADFConnectionType%>",$rec.ConnectionType `
        -replace "<%ADFRollingWindowDays%>",$rec.RollingWindowDays `
        -replace "<%ADFSQLScript%>",$rec.SQLScript `
        -replace "<%ADFPartitionSQLScript%>",$rec.PartitionSQLScript `
        -replace "<%ADFSqlType%>",$rec.AzureSQLType `
        -replace "<%ADFSCD2Columns%>",$rec.SCD2Columns `
        -replace "<%ADFRecursive%>",$rec.LoopFile `
        -replace "<%ADFNavisionCompanies%>",$rec.NavisionCompanies `
        -replace "<%ADFSqlType%>",$rec.AzureSQLType `
        -replace "<%ADFIsDateFlag%>",$rec.IsDateFlag `
        -replace "<%ADFIncrementalDefinition%>",$rec.IncrementalValueColumnDefinitionInExtract `

        Write-Host "Generating pipline" $rec.ExtractPackageName"...." -ForegroundColor Yellow  -NoNewline
        Write-Host "Done"-ForegroundColor Green    

        Set-Content -Path ($ADFPath+"pipeline\" + $rec.ExtractPackageName` + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($template_pipeline).ToString()) -NoNewline

}

write-host ""
write-host "============================="
write-host "Disabling SourceObject Items"
write-host "============================="
write-host "" 
write-host ""
write-host "Disabling SourceObject Items..." -NoNewline

foreach ($so in $SourceObjectDefinitions) {

    $Query = "UPDATE meta.SourceObjects SET ExcludeFlag = 1  WHERE ID = " + $so.SourceObjectID

    Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $Query

    }

Write-Host "Done"-ForegroundColor Green
