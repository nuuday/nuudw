  
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

Import-Module newtonsoft.json
Import-Module sqlserver
				
# =====================
# Set Variables
# =====================

$ScriptDirectory = (Get-Item -Path ".\").FullName

    . ("$($ScriptDirectory)\RunFrameworkVariables.ps1")

# Set working directory (where the .json ADF templates are located)
Set-Location $ADFPath

# =====================
# Datasets
# =====================

$BusinessMatrixDefinitions = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT * FROM meta.BusinessMatrixDefinitions WHERE TableName NOT IN ('Calendar','Time')"
$PackageDependencies = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT [ID],CloudControllerName AS [ControllerName],[SchemaName],[ControllerArea],[TableName],[PackageName],[ControllerExcludeFlag],[Generation],[PrevGeneration],[TopLevelName],[HasDependencyFlag],[ParentPackageDependencyName],[ParentPackageDependencyPackageName],[AverageDuration],[RowNo],[PrevRowNo],[PrevPrevRowNo],[IsLoadFlag],[ControllerPattern],[DatabaseName],[IsTransformFlag],[CloudControllerName] FROM meta.ControllerDefinitions WHERE ControllerArea <> 'Extract' AND (IsTransformFlag = 1 OR SchemaName = 'temp') AND ParentPackageDependencyPackageName IS NOT NULL"
$DistinctControllerDefinitions = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT DISTINCT CloudControllerName AS [ControllerName],[SchemaName],[ControllerArea],[TableName],[PackageName],[IsLoadFlag],[IsTransformFlag] FROM [meta].[ControllerDefinitions] WHERE ControllerArea <> 'Extract' AND TableName <> 'Time'"
$DistinctControllers = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT DISTINCT CloudControllerName AS [ControllerName],[ControllerArea],[DatabaseName] FROM [meta].[ControllerDefinitions] WHERE ControllerArea <> 'Extract'"
$ADFDatabase = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameMeta'"

# =====================
# Create Transform Procedures
# =====================

Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "EXECUTE [meta].[CreateTransformProcedures]"


write-host ""
write-host "# ============================="
write-host "# Create Calendar Pipeline"
write-host "# ============================="
write-host ""

#Calendar

foreach ($cal in $ADFDatabase) {

     $Calendar_Pipeline = (Get-Content ('Templates\Template_Pipeline_Load_Calendar.json') ) `
        -replace "<%ADFLinkedServiceName%>",$cal.VariableValue `

      Write-Host "Generating pipline LoadDimension_Calendar...." -ForegroundColor Yellow  -NoNewline
      Write-Host "Done"-ForegroundColor Green  

     Set-Content -Path ($ADFPath+"pipeline\LoadDimension_Calendar.json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($Calendar_Pipeline).ToString()) -NoNewline
   
}

write-host ""
write-host "# ============================="
write-host "# Create Transform and Load Pipelines"
write-host "# ============================="
write-host ""

foreach ($rec in $BusinessMatrixDefinitions) { 

    $MultipleSourcePostFix = ''
    if ($rec.SourceSystemDependentFlag -eq 1) { $MultipleSourcePostFix = '_MultipleSources' } 

    if (($rec.DestinationSchema -eq 'dim'))
    { 
        if ($rec.FactAndBridgeIncrementalFlag -eq 0)
         {
            $TransformPatternName = "Templates\Template_Pipeline_Transform_Full$MultipleSourcePostFix.json"
            $DimensionPatternName = "Templates\Template_Pipeline_Load_Dimension.json" 
          } 
        elseif ($rec.FactAndBridgeIncrementalFlag -eq 1)
        {
            $TransformPatternName = "Templates\Template_Pipeline_Transform_Incremental$MultipleSourcePostFix.json"
            $DimensionPatternName = "Templates\Template_Pipeline_Load_Dimension_Incremental.json" 
        }
         $FactPatternName = $null
    }
    elseif (($rec.FactAndBridgeIncrementalFlag -eq 1) -and ($rec.DestinationSchema -in 'fact','bridge'))
    {
        $TransformPatternName = "Templates\Template_Pipeline_Transform_IncrementalFact$MultipleSourcePostFix.json"
        $FactPatternName = 'Templates\Template_Pipeline_Load_Fact.json'
        $DimensionPatternName = $null
    }    
    elseif (($rec.FactAndBridgeIncrementalFlag -eq 0) -and ($rec.DestinationSchema -in 'fact','bridge'))
    {
        $TransformPatternName = "Templates\Template_Pipeline_Transform_Full$MultipleSourcePostFix.json"
        $FactPatternName = 'Templates\Template_Pipeline_Load_Fact.json'
        $DimensionPatternName = $null  
    }
    elseif (($rec.FactAndBridgeIncrementalFlag -eq 1) -and ($rec.DestinationSchema -eq 'temp'))
    {
        $TransformPatternName = "Templates\Template_Pipeline_Transform_Incremental$MultipleSourcePostFix.json"
        $FactPatternName = $null
        $DimensionPatternName = $null
    }
    elseif (($rec.FactAndBridgeIncrementalFlag -eq 0) -and ($rec.DestinationSchema -eq 'temp'))
    {
        $TransformPatternName = "Templates\Template_Pipeline_Transform_Full$MultipleSourcePostFix.json"
        $FactPatternName = $null
        $DimensionPatternName = $null
    }
       
    $StageSchemaName = "stage"
    if ($rec.DestinationSchema -eq 'temp') { $StageSchemaName = "stage_temp" }
     
    #Transform

    $Transform_Pipeline = (Get-Content ($TransformPatternName)) `
       -replace "<%ADFLinkedServiceName%>",$rec.DatabaseName `
       -replace "<%ADFSchemaName%>",$rec.DestinationSchema `
       -replace "<%ADFStageSchemaName%>",$StageSchemaName `
       -replace "<%ADFTableName%>",$rec.TableName ` 
      
     Write-Host "Generating pipline Transform_"$rec.TableName"...." -ForegroundColor Yellow  -NoNewline
     Write-Host "Done"-ForegroundColor Green  
          
     Set-Content -Path ($ADFPath+"pipeline\Transform_" + $rec.TableName` + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($Transform_Pipeline).ToString()) -NoNewline

    #Dimensions

    if ($DimensionPatternName -ne $null) {
    $Dimension_Pipeline = (Get-Content ($DimensionPatternName)) `
       -replace "<%ADFLinkedServiceName%>",$rec.DatabaseName `
       -replace "<%ADFTableName%>",$rec.TableName `  
    
     Write-Host "Generating pipline LoadDimension_"$rec.TableName"...." -ForegroundColor Yellow  -NoNewline
     Write-Host "Done"-ForegroundColor Green     

     Set-Content -Path ($ADFPath+"pipeline\LoadDimension_" + $rec.TableName` + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($Dimension_Pipeline).ToString()) -NoNewline
     }    
      

     #Facts and Bridges

    $FolderName = if ( $rec.DestinationSchema -eq 'bridge') {"3." + $rec.CapitalisedDestinationSchema} elseif ( $rec.DestinationSchema -eq 'fact') {"4." + $rec.CapitalisedDestinationSchema}

    if ($FactPatternName -ne $null) {
    $Fact_Pipeline = (Get-Content ($FactPatternName)) `
       -replace "<%ADFLinkedServiceName%>",$rec.DatabaseName `
       -replace "<%ADFTableName%>",$rec.TableName `
       -replace "<%ADFSchemaName%>",$rec.CapitalisedDestinationSchema `
       -replace "<%ADFFolderName%>",$FolderName `
       -replace "<%ADFLoadPattern%>",$rec.ExecutionPattern `  

     Write-Host "Generating pipline LoadD"$rec.CapitalisedDestinationSchema"_"$rec.TableName"...." -ForegroundColor Yellow  -NoNewline
     Write-Host "Done"-ForegroundColor Green    

     Set-Content -Path ($ADFPath+"pipeline\Load" + $rec.CapitalisedDestinationSchema` + "_" + $rec.TableName` + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse($Fact_Pipeline).ToString()) -NoNewline
     }
}

