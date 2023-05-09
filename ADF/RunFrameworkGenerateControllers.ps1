 
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
$AzureSubscriptionID = "3e00fd8f-f7ff-4f9b-8ba4-0a71e79e2522";

# =====================
# Login i Azure
# =====================

#NB!!! Make sure you are logged into the customer tenant in the PS Session. When this is done you do not need to login again in the session.
#Use the cmd below to login

#Login-AzAccount -Tenant 'f40d0f9e-0dfd-4ed9-9ab6-a81f49849649'

Select-AzSubscription $AzureSubscriptionID

# The connectionstring for the Azure SQL DB
$Secret = Get-AzKeyVaultSecret -VaultName "KV-WristBI-Dev" -Name "ConnectionString-WristBIDW"
$ConnectionString = $Secret.SecretValueText

# Set working directory (where the .json ADF templates are located)
Set-Location $ADFPath


# =====================
# Datasets
# =====================

$ControllerDefinitionsExtract = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT [ID],CloudControllerName AS [ControllerName],[SchemaName],[ControllerArea],[TableName],[PackageName],[ControllerExcludeFlag],[Generation],[PrevGeneration],[TopLevelName],[HasDependencyFlag],[ParentPackageDependencyName],[ParentPackageDependencyPackageName],[AverageDuration],[RowNo],[PrevRowNo],[PrevPrevRowNo],[IsLoadFlag],[ControllerPattern],[DatabaseName],[IsTransformFlag],[CloudControllerName] FROM meta.ControllerDefinitions WHERE ControllerArea = 'Extract'"
$DistinctControllersExtract = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT DISTINCT CloudControllerName AS [ControllerName],[ControllerArea],[DatabaseName],TopLevelName FROM [meta].[ControllerDefinitions] WHERE ControllerArea = 'Extract'"
$PackageDependencies = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT [ID],CloudControllerName AS [ControllerName],[SchemaName],[ControllerArea],[TableName],[PackageName],[ControllerExcludeFlag],[Generation],[PrevGeneration],[TopLevelName],[HasDependencyFlag],[ParentPackageDependencyName],[ParentPackageDependencyPackageName],[AverageDuration],[RowNo],[PrevRowNo],[PrevPrevRowNo],[IsLoadFlag],[ControllerPattern],[DatabaseName],[IsTransformFlag],[CloudControllerName] FROM meta.ControllerDefinitions WHERE ControllerArea <> 'Extract' AND (IsTransformFlag = 1 OR SchemaName = 'temp') AND ParentPackageDependencyPackageName IS NOT NULL"
$DistinctControllerDefinitionsLoad = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT DISTINCT CloudControllerName AS [ControllerName],[SchemaName],[ControllerArea],[TableName],[PackageName],[IsLoadFlag],[IsTransformFlag] FROM [meta].[ControllerDefinitions] WHERE ControllerArea <> 'Extract' AND TableName <> 'Time'"
$DistinctControllersLoad = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT DISTINCT CloudControllerName AS [ControllerName],[ControllerArea],[DatabaseName] FROM [meta].[ControllerDefinitions] WHERE ControllerArea <> 'Extract'"
$ADFDatabase = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "SELECT VariableValue FROM meta.Variables WHERE VariableName = 'DatabaseNameMeta'"

write-host ""
write-host "# ============================="
write-host "# Create Extract Controller Pipelines"
write-host "# ============================="
write-host ""

foreach ($con in $DistinctControllersExtract) {

$ControllerCode = (Get-Content ('Templates\Template_Pipeline_Controller_Extract.json') ) `
        -replace "<%ADFControllerName%>",$con.ControllerName `
        -replace "<%ADFControllerFolder%>",$con.TopLevelName `   
     

    $Controller = ($ControllerCode | ConvertFrom-Json)

    ($Controller.properties) | add-member -MemberType NoteProperty -Name "activities" -Value @() 
    foreach ($pack in $ControllerDefinitionsExtract  | Where-Object {$_.ControllerName -eq $con.ControllerName})
    {
        $packagename = $pack.PackageName.SubString(0,[math]::min(55,$pack.PackageName.length) )
        $Package = ('{"name": "' + $packagename + '","type": "ExecutePipeline","typeProperties":{"pipeline": {"referenceName": "' + $pack.PackageName + '","type": "PipelineReference"},"waitOnCompletion": true,"parameters": { "JobIsIncremental": "@pipeline().parameters.JobIsIncremental", "WriteBatchSize": "@pipeline().parameters.WriteBatchSize" }}}' | ConvertFrom-Json)
        $Controller.properties.activities += $Package
        $packagename = $null
    }

    Write-Host "Generating pipline" $con.ControllerName"...." -ForegroundColor Yellow  -NoNewline
    Write-Host "Done"-ForegroundColor Green  

  Set-Content -Path ($ADFPath+"pipeline\" + $con.ControllerName  + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse(( $Controller | ConvertTo-Json -Depth 50)).ToString()) -NoNewline

  }


write-host ""
write-host "# ============================="
write-host "# Create Load Controller Pipelines"
write-host "# ============================="
write-host ""

foreach ($con in $DistinctControllersLoad) {

$ControllerCode = (Get-Content ('Templates\Template_Pipeline_Controller_' + $con.ControllerArea +'.json') ) `
        -replace "<%ADFControllerName%>",$con.ControllerName `       

    $Controller = ($ControllerCode | ConvertFrom-Json)
    
    $Parameters = if ($con.ControllerArea -eq "Temp")
                  {
                    ',"parameters": { "JobIsIncremental": "@pipeline().parameters.JobIsIncremental"}'
                  }                    
                  elseif ($con.ControllerArea -eq "Dimensions")
                  {
                    ',"parameters": { "JobIsIncremental": "@pipeline().parameters.JobIsIncremental", "DisableMaintainDW": "@pipeline().parameters.DisableMaintainDW"}'
                  }                 
                  else 
                  {
                    ',"parameters": { "JobIsIncremental": "@pipeline().parameters.JobIsIncremental", "DisableMaintainDW": "@pipeline().parameters.DisableMaintainDW", "CleanUpPartitions": "@pipeline().parameters.CleanUpPartitions" }'
                  }

                      
    ($Controller.properties) | add-member -MemberType NoteProperty -Name "activities" -Value @() 
    
    foreach ($pack in $DistinctControllerDefinitionsLoad | Where-Object {$_.ControllerArea -eq $con.ControllerArea -and $_.ControllerName -eq $con.ControllerName}) 
    {

        $Transform = if ($pack.TableName -eq "Calendar" -and $pack.IsLoadFlag -eq 1 )
                     {
                        ""
                     }
                     elseif ($pack.TableName -ne "Calendar" -and $pack.IsLoadFlag -eq 1)
                     {
                        ',"dependsOn": [{"activity": "Transform_' + $pack.TableName + '","dependencyConditions": ["Succeeded"]}]'
                     }

        $Dependen = ""
        $Placeholder = ""
        $Counter = 1

        foreach ($dep in $PackageDependencies | Where-Object {$_.ControllerArea -eq $con.ControllerArea -and $_.ControllerName -eq $con.ControllerName -and $_.PackageName -eq $pack.PackageName}) 
        {
        $Comma = if($Counter -eq 1) {""} else {","} 
        $Placeholder  = $Comma + '{"activity": "' + $dep.ParentPackageDependencyPackageName + '","dependencyConditions": ["Succeeded"]}'                      
          
        $Dependen = $Dependen + $Placeholder
        $Counter = $Counter + 1

        }
        
      
        $Dependencies = if ($Dependen -eq "")
                        {
                         ""
                        }
                        else
                        {
                            ',"dependsOn": [' + $Dependen + ']'
                        }
                        
        $Package = ('{"name": "' + $pack.PackageName + '","type": "ExecutePipeline"' + $Transform + $Dependencies +',"typeProperties":{"pipeline": {"referenceName": "' + $pack.PackageName + '","type": "PipelineReference"},"waitOnCompletion": true' + $Parameters + '}}' | ConvertFrom-Json)
        $Controller.properties.activities += $Package
    }

    Write-Host "Generating pipline" $con.ControllerName"...." -ForegroundColor Yellow  -NoNewline
    Write-Host "Done"-ForegroundColor Green  
   
  Set-Content -Path ($ADFPath+"pipeline\" + $con.ControllerName + ".json") -Value ([Newtonsoft.Json.Linq.JObject]::Parse(( $Controller | ConvertTo-Json -Depth 50)).ToString()) -NoNewline

  }

  