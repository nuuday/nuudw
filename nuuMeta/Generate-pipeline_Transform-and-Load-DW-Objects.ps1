Param(
    [Parameter(Position=0,Mandatory=$true)]
    [string]$DWObjectIds
)

$ErrorActionPreference = "Stop"

#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

[Reflection.Assembly]::LoadWithPartialName("Newtonsoft.Json.dll")
IMPORT-Module sqlserver

# =====================
# Set Variables
# =====================


# Set SQL where-clause depending on input
if ($DWObjectIds -eq "*") {
    $SQLWhereClause = ""
} else {
    $SQLWhereClause = "AND DWObjectID IN ($DWObjectIds)"
}


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

#Login-AzAccount -Tenant 'c95a25de-f20a-4216-bc84-99694442c1b5'
#Select-AzSubscription $AzureSubscriptionID

# The connectionstring for the Azure SQL DB
$ConnectionString = Get-AzKeyVaultSecret -VaultName "nuudw-kv01-dev" -Name "ConnectionString-nuudwsqldb01" -AsPlainText


# =====================
# Datasets
# =====================

$DWObjectDefinitions = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT * FROM nuuMetaView.DWObjectDefinitions WHERE DWObjectName NOT IN ('Calendar','Time') $SQLWhereClause"
$ADFDatabase = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT VariableValue AS DBName FROM nuuMetaView.Variables WHERE VariableName = 'DatabaseNameMeta'"

# =====================
# Create Load and Transform pipelines
# =====================

Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "EXECUTE [nuuMeta].[CreateTransformProcedures]"

write-host ""
write-host "# ============================="
write-host "# Create Load and Transform Pipelines"
write-host "# ============================="
write-host ""

foreach ($rec in $DWObjectDefinitions) { 
    
    #Transform

    $TransformPatternName = $nuuMetaPath+'Templates\Template_Pipeline_Transform.json'
    
    $Transform_Pipeline = (Get-Content ($TransformPatternName)) `
       -replace "<%ADFLinkedServiceName%>",$ADFDatabase.DBName `
       -replace "<%ADFDWObjectName%>",$rec.DWObjectName `
       -replace "<%ADFTransformProcedureName%>",$rec.TransformProcedureName `
       -replace "<%ADFStageTableName%>",$rec.StageTableName `
       -replace "<%ADFPipelineFolder%>",$rec.PipelineFolder `
       -replace "<%ADFTransformPipelineName%>",$rec.TransformPipelineName `
       -replace "<%ADFLoadPipelineName%>",$rec.LoadPipelineName `

    Write-Host "Generating pipline $($rec.TransformPipelineName)..." -ForegroundColor Yellow -NoNewline
          
    Set-Content -Path ($ADFPath+"pipeline\" + $rec.TransformPipelineName + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($Transform_Pipeline).ToString()) -NoNewline

    Write-Host " Done"-ForegroundColor Green  



    #Load
    
    $DimensionPatternName = $null
    $FactPatternName = $null

    if ($rec.DWObjectType -eq 'Dimension') 
    { 
        $DimensionPatternName = 'Templates\Template_Pipeline_Load_Dimension.json'
        
    }
    elseif ($rec.DWObjectType -in 'Fact','Bridge')
    {
        $FactPatternName = 'Templates\Template_Pipeline_Load_Fact.json'        
    }  

    #Dimensions
    if ($DimensionPatternName -ne $null) {
        $Dimension_Pipeline = (Get-Content ($nuuMetaPath+$DimensionPatternName)) `
           -replace "<%ADFLinkedServiceName%>",$ADFDatabase.DBName `
           -replace "<%ADFStageTableName%>",$rec.StageTableName `
           -replace "<%ADFDWTableName%>",$rec.DWTableName `
           -replace "<%ADFPipelineFolder%>",$rec.PipelineFolder `
           -replace "<%ADFLoadPipelineName%>",$rec.LoadPipelineName `
           -replace "<%ADFLoadProcedure%>",$rec.LoadProcedure `
    
         Write-Host "Generating pipline $($rec.LoadPipelineName)..." -ForegroundColor Yellow -NoNewline

         Set-Content -Path ($ADFPath+"pipeline\" + $rec.LoadPipelineName + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($Dimension_Pipeline).ToString()) -NoNewline

         Write-Host " Done"-ForegroundColor Green 
   
     }    


    #Facts and Bridges    
    if ($FactPatternName -ne $null) {
        $Fact_Pipeline = (Get-Content ($nuuMetaPath+$FactPatternName)) `
           -replace "<%ADFLinkedServiceName%>",$ADFDatabase.DBName `
           -replace "<%ADFDWSchemaName%>",$rec.DWSchemaName `
           -replace "<%ADFDWTableName%>",$rec.DWTableName `
           -replace "<%ADFStageSchemaName%>",$rec.StageSchemaName `
           -replace "<%ADFStageTableName%>",$rec.StageTableName `
           -replace "<%ADFPipelineFolder%>",$rec.PipelineFolder `
           -replace "<%ADFLoadPattern%>",$rec.LoadPattern `
           -replace "<%ADFLoadPipelineName%>",$rec.LoadPipelineName `
           -replace "<%ADFLoadProcedure%>",$rec.LoadProcedure `

         Write-Host "Generating pipline $($rec.LoadPipelineName)...." -ForegroundColor Yellow  -NoNewline

         Set-Content -Path ($ADFPath+"pipeline\" + $rec.LoadPipelineName + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($Fact_Pipeline).ToString()) -NoNewline

         Write-Host " Done"-ForegroundColor Green    
     }


    
    #Controller    
    if ($rec.DWObjectType -eq 'Link') {
        $ControllerPatternName = $nuuMetaPath+'Templates\Template_Pipeline_Controller_DW_Exclude_Load.json'
    } else {
        $ControllerPatternName = $nuuMetaPath+'Templates\Template_Pipeline_Controller_DW.json'
    }

    $Controller_Pipeline = (Get-Content ($ControllerPatternName)) `
        -replace "<%ADFLinkedServiceName%>",$ADFDatabase.DBName `
        -replace "<%ADFStageTableName%>",$rec.StageTableName `
        -replace "<%ADFDWTableNamee%>",$rec.DWTableName `
        -replace "<%ADFPipelineFolder%>",$rec.PipelineFolder `
        -replace "<%ADFTransformPipelineName%>",$rec.TransformPipelineName `
        -replace "<%ADFLoadPipelineName%>",$rec.LoadPipelineName `
        -replace "<%ADFControllerPipelineName%>",$rec.ControllerPipelineName `

    Write-Host "Generating pipline $($rec.ControllerPipelineName)...." -ForegroundColor Yellow  -NoNewline

    Set-Content -Path ($ADFPath+"pipeline\" + $rec.ControllerPipelineName + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($Controller_Pipeline).ToString()) -NoNewline

    Write-Host " Done"-ForegroundColor Green    
  

}

