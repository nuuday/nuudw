Param(
    [Parameter(Position=0,Mandatory=$true)]
    [string]$DWObjectIds
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


# =====================
# Login i Azure
# =====================

#Connect-AzAccount -TenantId "c95a25de-f20a-4216-bc84-99694442c1b5" -SubscriptionId "155e9e90-807a-43a9-811b-8f7bdb95a801"


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

    #MaintainDW

    $MaintainDWPatternName = $nuuMetaPath+'Templates\Template_Pipeline_MaintainDW.json'

    $MaintainDW_Pipeline = (Get-Content ($MaintainDWPatternName)) `
       -replace "<%LinkedServiceName%>",$ADFDatabase.DBName `
       -replace "<%DWSchemaName%>",$rec.DWSchemaName `
       -replace "<%DWTableName%>",$rec.DWTableName `

    Write-Host "Generating pipline $($rec.MaintainDWPipelineName)..." -ForegroundColor Yellow -NoNewline
          
    Set-Content -Path ($ADFPath+"pipeline\" + $rec.MaintainDWPipelineName + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($MaintainDW_Pipeline).ToString()) -NoNewline

    Write-Host " Done"-ForegroundColor Green  


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

