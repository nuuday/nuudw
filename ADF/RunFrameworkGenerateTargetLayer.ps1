 
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

$TargetObject = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT DISTINCT TargetObjectID FROM meta.TargetObjectDefinitions"

write-host ""
write-host "============================="
write-host "Updating Meta Tables"
write-host "============================="
write-host "" 
write-host ""
write-host "Updating Meta Tables..." -NoNewline

$SQL = ""

foreach ($rec in $TargetObject) {
 $PlaceholderSQL = "EXECUTE [meta].[MaintainTarget] @TargetObjectID = '" + $rec.TargetObjectID + "'
 "
 $SQL = $SQL + $PlaceholderSQL
 $PlaceholderSQL = ""

}

if ($SQL.Length -eq 0) {
    write-host "No targetobjects enabled in meta.TargetObjects" -ForegroundColor Red
    } else {
    Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $SQL

    Write-Host "Done"-ForegroundColor Green
    }
    
$TargetObjectDefinitions = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT * FROM meta.TargetObjectDefinitions" -MaxCharLength 12000
$ControllerDefinitions = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT [ID],CloudControllerName AS [ControllerName],[SchemaName],[ControllerArea],[TableName],[PackageName],[ControllerExcludeFlag],[Generation],[PrevGeneration],[TopLevelName],[HasDependencyFlag],[ParentPackageDependencyName],[ParentPackageDependencyPackageName],[AverageDuration],[RowNo],[PrevRowNo],[PrevPrevRowNo],[IsLoadFlag],[ControllerPattern],[DatabaseName],[IsTransformFlag],[CloudControllerName] FROM meta.ControllerDefinitions WHERE ControllerArea = 'Extract'"
$DistinctControllers = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT DISTINCT CloudControllerName AS [ControllerName],[ControllerArea],[DatabaseName] FROM [meta].[ControllerDefinitions] WHERE ControllerArea = 'Extract'"
$ADFDatabase = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT VariableValue, 'AzureSqlTable' AS ObjectType FROM meta.Variables WHERE VariableName = 'DatabaseNameMeta'" 
$SourceConnections = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT DISTINCT  [SourceConnectionName],[SourceObjectType],[SourceDatasetPattern],[SourceDatasetName], [SourceIsFileObject] FROM [meta].[TargetObjectDefinitions]"
$TargetConnections = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT DISTINCT  [TargetConnectionName],[TargetObjectType],[TargetDatasetPattern],[TargetDatasetName],[TargetAzureFileTypeName] FROM [meta].[TargetObjectDefinitions] UNION ALL SELECT DISTINCT  [Name],'AzureSQLDWTable' AS [TargetObjectType],'AzureSqlDW' AS [TargetDatasetPattern],[Name] + '_DynamicDataset' AS [TargetDatasetName],'' AS [TargetAzureFileTypeName] FROM [meta].[TargetConnections] WHERE ConnectionType = 'AzureSqlDW'"


write-host ""
write-host "# ============================="
write-host "# Create Datasets"
write-host "# ============================="
write-host ""



foreach ($rec in $ADFDatabase) {

    $DatabaseName = $rec.VariableValue

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

        $SourceDatasetName = ($con.SourceConnectionName + "_DynamicDataset")

        $SourceDataset = (Get-Content ('Templates\Template_Dataset_Standard.json') ) `
			-replace "<%ADFLinkedServiceName%>",$con.SourceConnectionName `
			-replace "<%ADFDatasetType%>",$con.SourceObjectType `
            -replace "<%ADFFolderName%>","DynamicDatasets" `
            -replace "<%ADFDatasetName%>",$SourceDatasetName `
                   
        Write-Host "Generating"$con.ObjectType"dataset"$SourceDatasetName"...." -ForegroundColor Yellow  -NoNewline
        Write-Host "Done"-ForegroundColor Green  

		# Set dynamic datasets
		Set-Content -Path ($ADFPath + "dataset\" + $con.SourceConnectionName + "_DynamicDataset.json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($SourceDataset).ToString()) -NoNewline
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
                $datasetSettings += ', "rowDelimiter": { "value": "@dataset().RowSeperator", "type": "Expression" }'
                $datasetSettings += ', "columnDelimiter": { "value": "@dataset().ColumnDelimiter", "type": "Expression" }'
                $datasetSettings += ', "escapeChar": { "value": "@dataset().EscapeCharacter", "type": "Expression" }'
                $datasetSettings += ', "quoteChar": { "value": "@dataset().TextQualifier", "type": "Expression" }'
                $datasetSettings += ', "firstRowAsHeader": { "value": "@dataset().IsHeaderPresent", "type": "Expression" }'
            }

           
            $dataSetName = $con.SourceConnectionName+"_"+$filetype+"_DynamicDataset"

			$DatasetExtractInformationSchemaSource = (Get-Content ('Templates\Template_Dataset_Flatfile.json') ) `
            -replace "<%ADFLinkedServiceName%>",$con.SourceConnectionName `
            -replace "<%ADFDatasetName%>", $dataSetName `
            -replace "<%ADFFolderName%>","DynamicDatasets" `
            -replace "<%ADFAzureFileTypeName%>",$filetype `
            -replace "<%ADFDatasetType%>",$con.SourceObjectType `
            -replace "<%ADFDatasetSettings%>",$datasetSettings `


			Write-Host "Generating FlatFile dataset"$dataSetName"...." -ForegroundColor Yellow  -NoNewline
            Write-Host "Done"-ForegroundColor Green  

			# Set datasets
			Set-Content -Path ($ADFPath + "dataset\"+ $dataSetName +".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($DatasetExtractInformationSchemaSource).ToString()) -NoNewline
		}
	}

}    


# Get table metadata for generation

foreach ($rec in $TargetConnections) {  
    $datasetSettings = ''

    # Set compression codec depending on file type
    if ($rec.TargetAzureFileTypeName -eq 'Avro') 
    { 
        $datasetSettings += ', "avroCompressionCodec": {"value": "@dataset().CompressionCodec","type": "Expression"}' 
    }
    elseif ($rec.TargetAzureFileTypeName -eq 'Parquet' -Or $rec.TargetAzureFileTypeName -eq 'DelimitedText') 
    { 
        $datasetSettings += ', "compressionCodec": {"value": "@dataset().CompressionCodec","type": "Expression"}' 
    }  
            
    if ($rec.TargetAzureFileTypeName -eq 'DelimitedText') {
        $datasetSettings += ', "rowDelimiter": { "value": "@dataset().RowSeperator", "type": "Expression" }'
        $datasetSettings += ', "columnDelimiter": { "value": "@dataset().ColumnDelimiter", "type": "Expression" }'
        $datasetSettings += ', "escapeChar": { "value": "@dataset().EscapeCharacter", "type": "Expression" }'
        $datasetSettings += ', "quoteChar": { "value": "@dataset().TextQualifier", "type": "Expression" }'
        $datasetSettings += ', "firstRowAsHeader": { "value": "@dataset().IsHeaderPresent", "type": "Expression" }'
    }

    $DatasetDestinationCode = (Get-Content ('Templates\Template_Dataset_' + $rec.TargetDatasetPattern + '.json') ) `
        -replace "<%ADFLinkedServiceName%>",$rec.TargetConnectionName `
        -replace "<%ADFDatasetType%>",$rec.TargetObjectType  `
        -replace "<%ADFDatasetName%>",$rec.TargetDatasetName `
        -replace "<%ADFFolderName%>","DynamicDatasets" `
        -replace "<%ADFAzureFileTypeName%>",$rec.TargetAzureFileTypeName `
        -replace "<%ADFDatasetType%>",$con.ObjectType `
        -replace "<%ADFDatasetSettings%>",$datasetSettings ` 
 
    Write-Host "Generating target datasets"$rec.TargetDatasetName"...." -ForegroundColor Yellow  -NoNewline
    Write-Host "Done"-ForegroundColor Green  

    Set-Content -Path ($ADFPath +"dataset\" + $rec.TargetDatasetName + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($DatasetDestinationCode).ToString()) -NoNewline
}

write-host ""
write-host "# ============================="
write-host "# Create Target Pipelines"
write-host "# ============================="
write-host ""

foreach ($rec in $TargetObjectDefinitions) {

              
            $ADFFolderName = "Target/Extract_" + $rec.TargetConnectionName

            $ExtractTemplate = ($rec.TemplateName + $rec.TargetExtractPattern)   
            $ExtractTemplate += ".json"                    

            # Debug write
            Write-Host ("Using template: "+$ExtractTemplate) -ForegroundColor Green

            $SourceFileSystemName = IF ([string]::IsNullOrWhitespace($rec.SourceFileSystem)){$rec.SourceConnectionName} else {$rec.SourceFileSystem}


    $template_pipeline = (Get-Content ($ExtractTemplate)) `
        -replace "<%ADFPipelineName%>",$rec.ExtractPackageName `
        -replace "<%ADFSourceDatasetName%>",$rec.SourceDatasetName `
        -replace "<%ADFExtractSchemaName%>",$rec.TargetExtractSchemaName `
        -replace "<%ADFSourceSchemaName%>",$rec.SourceSchemaName `
        -replace "<%ADFTableName%>",$rec.SourceTableName `
        -replace "<%ADFSourceTable%>",$rec.SourceTable `
        -replace "<%ADFTargetTable%>",$rec.SourceExtractTableName `
        -replace "<%ADFDestinationDatasetName%>", $rec.TargetDatasetName `
        -replace "<%ADFCopySourceType%>",$rec.ADFCopySourceType `
        -replace "<%ADFCopyTargetType%>",$rec.ADFCopyTargetType `
        -replace "<%ADFDestinationLinkedService%>",$rec.TargetConnectionName `
        -replace "<%ADFFolderName%>",$ADFFolderName `
        -replace "<%ADFConnectionName%>",$rec.SourceConnectionName `
        -replace "<%ADFSourceConnectionType%>",$rec.SourceConnectionType `
        -replace "<%ADFRollingWindowDays%>",$rec.TargetRollingWindowDays `
        -replace "<%ADFFileSystem%>",$rec.TargetFileSystemName `
        -replace "<%ADFFileFolder%>",$rec.TargetFolderName `
        -replace "<%ADFFileName%>",$rec.TargetFileName `
        -replace "<%ADFAzureDWSchemaName%>",$rec.TargetExtractSchemaName `
        -replace "<%ADFSourceFileSystem%>",$SourceFileSystemName `
        -replace "<%ADFSourceFileFolder%>",$rec.SourceFileFolder `
        -replace "<%ADFSourceFileName%>",($rec.SourceFileName+"."+$rec.SourceFileExtension) `
        -replace "<%ADFAppendFileName%>",$rec.TargetAppendFileName `
        -replace "<%ADFDummyFileName%>",$rec.TargetDummyFileName `
        -replace "<%ADFSQLScript%>",$rec.SQLScript `
        -replace "<%ADFConnectionSQLScript%>",$rec.ConnectionSQLScript `
        -replace "<%ADFCreateTableSQLScript%>",$rec.CreateTableSQLScript `
        -replace "<%ADFDropTableSQLScript%>",$rec.DropTableSQLScript `
        -replace "<%ADFPartitionSQLScript%>",$rec.PartitionSQLScript `
        -replace "<%ADFAzureDWSQLScript%>",$rec.AzureDWSQLScript `
        -replace "<%ADFAzureFileTypeName%>",$rec.TargetAzureFileTypeName `
        -replace "<%ADFFileExtension%>",$rec.TargetFileExtensionName `
        -replace "<%ADFSqlType%>",$rec.SourceAzureSQLType `
        -replace "<%ADFAzureSqlDWName%>",$rec.TargetAzureSqlDWName `
        -replace "<%ADFDatabaseName%>",$DatabaseName `
        -replace "<%ADFSCD2Columns%>",$rec.SCD2Columns `
        -replace "<%ADFNavisionCompanies%>",$rec.NavisionCompanies `
        -replace "<%ADFIsDateFlag%>",$rec.TargetIsDateFlag `
        -replace "<%ADFIncrementalDefinition%>",$rec.TargetIncrementalValueColumnDefinitionInExtract `
        -replace "<%ADFConnectionType%>",$rec.TargetConnectionType `
        -replace "<%ADFDatasetType%>",$rec.TargetObjectType  `
      #  -replace "<%ADFCopySourceQueryProperty%>",$rec.ADFCopySourceType `

        Write-Host "Generating pipeline" $rec.ExtractPackageName"...." -ForegroundColor Yellow  -NoNewline
        Write-Host "Done"-ForegroundColor Green    

        Set-Content -Path ($ADFPath+"pipeline\" + $rec.ExtractPackageName` + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($template_pipeline).ToString()) -NoNewline
       
      
}

write-host ""
write-host "============================="
write-host "Disabling TargetObjects Items"
write-host "============================="
write-host "" 
write-host ""
write-host "Disabling TargetObjects Items..." -NoNewline

foreach ($so in $TargetObjectDefinitions) {

    $Query = "UPDATE meta.TargetObjects SET ExcludeFlag = 1  WHERE ID = " + $so.TargetObjectID

    Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $Query

    }

Write-Host "Done"-ForegroundColor Green
