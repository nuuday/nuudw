Param(
    [Parameter(Position=0,Mandatory=$true)]
    [string]$SourceConnectionId
)

$ErrorActionPreference = "Stop"

#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

[Reflection.Assembly]::LoadWithPartialName("Newtonsoft.Json.dll")
IMPORT-Module sqlserver

# =====================
# Set Variables
# =====================

# Set SQL where-clause depending on input

$SQLWhereClause = "SourceConnectionId IN ($($SourceConnectionId))"


# Set paths
Set-Location $($PSScriptRoot + "\")
Set-Location ..
$ReposPath = $(Get-Location).Path
$nuuMetaPath = $ReposPath + '\nuuMeta\'
$ADFPath = $ReposPath + '\ADF\'


# The subscription ID for the Azure environment
$AzureSubscriptionID = "155e9e90-807a-43a9-811b-8f7bdb95a801";

# =====================
# Login i Azure
# =====================

Login-AzAccount -Tenant 'c95a25de-f20a-4216-bc84-99694442c1b5'
Select-AzSubscription $AzureSubscriptionID

#Connect-AzAccount -TenantId "c95a25de-f20a-4216-bc84-99694442c1b5" -SubscriptionId "155e9e90-807a-43a9-811b-8f7bdb95a801"

# The connectionstring for the Azure SQL DB
$ConnectionString = Get-AzKeyVaultSecret -VaultName "nuudw-kv01-dev" -Name "ConnectionString-nuudwsqldb01" -AsPlainText
$KeyVaultPrefix = Get-AzKeyVaultSecret -VaultName "nuudw-kv01-dev" -Name "KeyVaultPrefix"


# =====================
# Datasets
# =====================

$SourceConnections     = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT [SourceConnectionName], [SourceConnectionType], [SourceObjectType], [IsFileObject], [DestinationSchemaName] FROM [nuuMetaView].[SourceConnectionDefinitions] WHERE $($SQLWhereClause)"
$ADFDatabase = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT VariableValue AS DBName, 'AzureSqlTable' AS ObjectType FROM nuuMetaView.Variables WHERE VariableName = 'DatabaseNameMeta'"
$NuuDLSQLLinkedService = (Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT VariableValue FROM nuuMetaView.Variables WHERE VariableName = 'DataLakeSQLLinkedService'").VariableValue
#$NuuDLLinkedService    = (Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT VariableValue, 'DataLakeLinkedService' AS ObjectType FROM meta.Variables WHERE VariableName = 'DataLakeLinkedService'").VariableValue


$DatasetName = ($rec.VariableValue + "_DynamicDataset")
 
$DatasetSourceInformationSchemaSource = (Get-Content ($nuuMetaPath+'templates\Template_Dataset_Standard.json') ) `
	-replace "<%ADFLinkedServiceName%>",$ADFDatabase.DBName `
	-replace "<%ADFDatasetType%>",$ADFDatabase.ObjectType `
    -replace "<%ADFFolderName%>","DynamicDatasets" `
    -replace "<%ADFDatasetName%>",($ADFDatabase.DBName + "_DynamicDataset") `

<#    
$DatasetSourceInformationSchemaDestination = (Get-Content ($nuuMetaPath+'templates\Template_Dataset_SourceInformationSchema.json') ) `
	-replace "<%ADFLinkedServiceName%>",$ADFDatabase.DBName `
	-replace "<%ADFDatasetType%>",$ADFDatabase.ObjectType `
#>	

# Set datasets
Set-Content -Path ($ADFPath + "dataset\" + $ADFDatabase.DBName + "_DynamicDataset.json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($DatasetSourceInformationSchemaSource).ToString()) -NoNewline
#Set-Content -Path ($ADFPath + "dataset\Meta_SourceInformationSchema_" + $ADFDatabase.DBName + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($DatasetSourceInformationSchemaDestination).ToString()) -NoNewline


foreach ($con in $SourceConnections) {

	if ($con.IsFileObject -eq 0) {

        # Default values
        $template = $nuuMetaPath+'templates\Template_Dataset_Standard.json'
        $SourceDatasetName = ($con.SourceConnectionName + "_DynamicDataset")
        $folder = 'DynamicDatasets'
	
        # AzureDatabricksDeltaLake 
        if ($con.SourceConnectionType -eq 'AzureDatabricksDeltaLake') {
            $template = $nuuMetaPath+'templates\Template_Dataset_AzureDatabricksDeltaLake.json'
        }

        $DatasetSourceInformationSchemaSource = (Get-Content ($template) ) `
			-replace "<%ADFLinkedServiceName%>" , $con.SourceConnectionName `
			-replace "<%ADFDatasetType%>"       , $con.SourceObjectType `
            -replace "<%ADFFolderName%>"        , $folder `
            -replace "<%ADFDatasetName%>"       , $SourceDatasetName `
         
		# Set dynamic datasets
		Set-Content -Path ($ADFPath + "dataset\" + $SourceDatasetName + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($DatasetSourceInformationSchemaSource).ToString()) -NoNewline

    } 

}


foreach ($row in $SourceConnections) {  
    
    $PipeLineName = "EXT_Schema_" + $row.SourceConnectionName
    $DatabaseName = $ADFDatabase.DBName
    $LinkedService = $row.SourceConnectionName;

    $template_pipeline = (Get-Content ($nuuMetaPath+'templates\Template_Pipeline_Extract_' + $row.SourceConnectionType + '_Schema.json')) `
        -replace "<%ADFPipeLineName%>"          , $PipeLineName `
        -replace "<%ADFLinkedServiceName%>"     , $LinkedService `
        -replace "<%ADFConnectionTypeName%>"    , $row.SourceConnectionType `
        -replace "<%ADFDestinationSchemaName%>" , $row.DestinationSchemaName `
        -replace "<%ADFDatabaseName%>"          , $DatabaseName `
		-replace "<%KeyVaultPrefix%>"           , $KeyVaultPrefix.SecretValueText `
        -replace "<%ADFObjectName%>"            , $row.SourceConnectionName `
        -replace "<%ADFNuuDLSQLLinkedService%>" , $NuuDLSQLLinkedService `
        -replace "<%ADFFolder%>"                , '0.9_Meta' `

    Write-Host "Generating pipeline" $PipeLineName"...." -ForegroundColor Yellow  -NoNewline
    Write-Host "Done"-ForegroundColor Green   

    Set-Content -Path ($ADFPath+"pipeline\" + $PipeLineName + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($template_pipeline).ToString()) -NoNewline
     
}

