Param(
    [Parameter(Position=0,Mandatory=$true)]
    [string]$SourceConnectionIds
)

$ErrorActionPreference = "Stop"

#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# =====================
# Check installed modules
# =====================

$requiredModules = @("sqlserver", "Az.Accounts", "Az.KeyVault")

foreach ($module in $requiredModules) {

    $exit = 0

    if (-not (Get-Module -ListAvailable -Name $module*)) {
        Write-Host "Required module '$module' is not installed. Please install the module and try again." -ForegroundColor Yellow
        Write-Host "Install-Module -Name '$module' -AllowClobber -Scope AllUsers" -ForegroundColor Green
        $exit = 1
    }

}

if ($exit -eq 1) {
    exit
}


Import-Module sqlserver
Import-Module Az.Accounts
Import-Module Az.KeyVault

[Reflection.Assembly]::LoadWithPartialName("Newtonsoft.Json.dll")

# =====================
# Set Variables
# =====================

# Set SQL where-clause depending on input
$SQLWhereClause = "SourceConnectionId IN ($($SourceConnectionIds))"


# Set paths
Set-Location $($PSScriptRoot + "\")
Set-Location ..
$ReposPath = $(Get-Location).Path
$nuuMetaPath = $ReposPath + '\nuuMeta\'
$ADFPath = $ReposPath + '\ADF\'


# =====================
# Login i Azure
# =====================

Connect-AzAccount -TenantId "c95a25de-f20a-4216-bc84-99694442c1b5" -SubscriptionId "155e9e90-807a-43a9-811b-8f7bdb95a801"


# The connectionstring for the Azure SQL DB
$ConnectionString = Get-AzKeyVaultSecret -VaultName "nuudw-kv01-dev" -Name "ConnectionString-nuudwsqldb01" -AsPlainText
$KeyVaultPrefix = Get-AzKeyVaultSecret -VaultName "nuudw-kv01-dev" -Name "KeyVaultPrefix"

$SourceObjectDefinitions = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT * FROM nuuMetaView.SourceObjectDefinitions WHERE $($SQLWhereClause)" -MaxCharLength 12000
$SourceConnectionDefinitions = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT [SourceConnectionName], [SourceObjectType], SourceConnectionType, 0 AS SourceIsFileObject FROM [nuuMetaView].[SourceConnectionDefinitions] WHERE $($SQLWhereClause)"
$ADFDatabase = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT VariableValue AS DBName, 'AzureSqlTable' AS ObjectType FROM nuuMetaView.Variables WHERE VariableName = 'DatabaseNameMeta'"
$NuuDLStagingLinkedService = (Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT VariableValue FROM nuuMetaView.Variables WHERE VariableName = 'NUUDLStagingLinkedService'").VariableValue

$ExtractControllerDefinitions = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT * FROM nuuMetaView.ExtractControllerDefinitions WHERE $($SQLWhereClause)"
$DistinctExtractControllerDefinitions = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT DISTINCT ADFControllerName, ADFFolder FROM [nuuMetaView].[ExtractControllerDefinitions] WHERE $($SQLWhereClause)"



write-host ""
write-host "============================="
write-host "Create Extract Pipelines"
write-host "============================="
write-host ""

foreach ($obj in $SourceObjectDefinitions) {

    $ADFCopySourceType = $obj.ADFCopySourceType
    $ADFFolderName = "0.1_Extracts"
    

    $ExtractTemplate = $obj.TemplateName   
    $ExtractTemplate += ".json"  
    
    $template_pipeline = (Get-Content ($nuuMetaPath+'templates\'+$ExtractTemplate)) `
        -replace "<%ADFFolderName%>",$ADFFolderName `
        -replace "<%ADFPipelineName%>",$obj.ADFPipelineName `
        -replace "<%ADFSourceQuery%>",$obj.SourceQuery `
        -replace "<%ADFSourceIsReadyQuery%>",$obj.SourceIsReadyQuery `
        -replace "<%ADFSourceConnection%>",$obj.SourceConnectionName `
        -replace "<%ADFSourceConnectionType%>",$obj.SourceConnectionType `
        -replace "<%ADFSourceDatasetName%>",$obj.SourceDatasetName `
        -replace "<%ADFSourceSchema%>",$obj.SourceSchemaName `
        -replace "<%ADFSourceTable%>",$obj.SourceObjectName `
        -replace "<%ADFSourceFileSystem%>",$obj.FileSystem `
        -replace "<%ADFSourceFileFolder%>",$obj.Folder `
        -replace "<%ADFSourceFileName%>",$obj.FullFileName `
        -replace "<%ADFDestinationLinkedService%>",$ADFDatabase.DBName `
        -replace "<%ADFDestinationSchema%>",$obj.DestinationSchemaName `
        -replace "<%ADFDestinationTable%>",$obj.DestinationTableName `
        -replace "<%ADFDestinationDatasetName%>", $($ADFDatabase.DBName + "_DynamicDataset") `
        -replace "<%ADFHistoryTrackingColumns%>",$obj.HistoryTrackingColumns `
        -replace "<%ADFCopySourceType%>",$obj.ADFCopySourceType`
        -replace "<%ADFWatermarkColumnName%>",$obj.WatermarkColumnName `
        -replace "<%ADFWatermarkIsDate%>",$obj.WatermarkIsDate `
        -replace "<%ADFWatermarkInQuery%>",$obj.WatermarkInQuery `
        -replace "<%ADFWatermarkRollingWindowDays%>",$obj.WatermarkRollingWindowDays `
        -replace "<%ADFRollingWindowDays%>",$obj.WatermarkRollingWindowDays `
        -replace "<%ADFPartitionSQLScript%>",$obj.PartitionSQLScript `
        -replace "<%ADFSqlType%>",$obj.AzureSQLType `
        -replace "<%KeyVaultPrefix%>",$KeyVaultPrefix.SecretValueText `
        -replace "<%VariableSchemaNameSecret%>",$obj.SchemaName `
        -replace "<%ADFNuuDLStagingLinkedService%>", $NuuDLStagingLinkedService `
        
        Write-Host "Generating pipeline" $obj.ADFPipelineName"...." -ForegroundColor Yellow  -NoNewline
        
        Set-Content -Path ($ADFPath+"pipeline\" + $obj.ADFPipelineName` + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($template_pipeline).ToString()) -NoNewline

        Write-Host " Done"-ForegroundColor Green    

}

write-host ""
write-host "============================="
write-host "Create Extract Controller Pipelines"
write-host "============================="
write-host ""


foreach ($ctrl in $DistinctExtractControllerDefinitions) {

    $ControllerCode = (Get-Content ($nuuMetaPath+'templates\Template_Pipeline_Controller_Extract.json') ) `
        -replace "<%ADFControllerName%>",$ctrl.ADFControllerName `
        -replace "<%ADFControllerFolder%>",$ctrl.ADFFolder `   
     

    $Controller = ($ControllerCode | ConvertFrom-Json)

    ($Controller.properties) | add-member -MemberType NoteProperty -Name "activities" -Value @() 

    foreach ($pack in $ExtractControllerDefinitions) {
       
        $ActivityName = $pack.ADFPipelineActivityName.SubString(0,[math]::min(55,$pack.ADFPipelineActivityName.length) )
        $Package = ('{"name": "' + $ActivityName + '","type": "ExecutePipeline","typeProperties":{"pipeline": {"referenceName": "' + $pack.ADFPipelineName + '","type": "PipelineReference"},"waitOnCompletion": true,"parameters": { "JobIsIncremental": "@pipeline().parameters.JobIsIncremental", "WriteBatchSize": "@pipeline().parameters.WriteBatchSize" }}}' | ConvertFrom-Json)
        
        if ($ctrl.ADFControllerName -eq $pack.ADFControllerName) {
            $Controller.properties.activities += $Package
        }
        
        $ActivityName = $null
    
    }

    Write-Host "Generating pipline" $ctrl.ADFControllerName"...." -ForegroundColor Yellow  -NoNewline

    Set-Content -Path ($ADFPath+"pipeline\" + $ctrl.ADFControllerName  + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse(( $Controller | ConvertTo-Json -Depth 50)).ToString()) -NoNewline

    Write-Host " Done"-ForegroundColor Green  

  }
