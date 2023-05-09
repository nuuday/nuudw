param(
[Parameter (Mandatory = $false)][object] $WebhookData
)

#####################################################################
# ADF POST HTTP Call information
$body = (ConvertFrom-Json -InputObject $WebhookData.RequestBody)
$uri = $body.callBackUri
$KeyVault = $body.parameters.KeyVault 
$ModelName = $body.parameters.ModelName
$JobIsIncremental = $body.parameters.JobIsIncremental
$CleanUpPartitions = $body.parameters.CleanUpPartitions
#####################################################################


write-Output ""
write-Output "======================================================="
write-Output "Authenticating..."
write-Output "======================================================="
write-Output ""

$connection = Get-AutomationConnection -Name AzureRunAsConnection

Connect-AzAccount `
                               -ServicePrincipal `
                               -Tenant $connection.TenantID `
                               -ApplicationID $connection.ApplicationID `
                               -CertificateThumbprint $connection.CertificateThumbprint

write-Output ""
write-Output "======================================================="
write-Output "Done"
write-Output "======================================================="
write-Output ""
write-Output "======================================================="
write-Output "Getting Secrets from KeyVault..."
write-Output "======================================================="
write-Output ""


$DWNamePlaceholder = Get-AzKeyVaultSecret -VaultName $KeyVault -Name "SSMSDatabaseName"
$DWNamePlaceholderBTSR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($DWNamePlaceholder.SecretValue)
$DWName = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($DWNamePlaceholderBTSR)

$ConnectionStringDWSecret = "ConnectionString-" + $DWName

$ConnectionStringDWPlaceholder = Get-AzKeyVaultSecret -VaultName $KeyVault -Name $ConnectionStringDWSecret
$ConnectionStringDWPlaceholderBTSR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ConnectionStringDWPlaceholder.SecretValue)
$ConnectionStringDW = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ConnectionStringDWPlaceholderBTSR)

$ConnectionStringSSASPlaceholder = Get-AzKeyVaultSecret -VaultName $KeyVault -Name "SSASConnectionString"
$ConnectionStringSSASBTSR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ConnectionStringSSASPlaceholder.SecretValue)
$ConnectionStringSSAS = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ConnectionStringSSASBTSR)

$ServerPlaceholder = Get-AzKeyVaultSecret -VaultName $KeyVault -Name "SSASServerName"
$ServerPlaceholderBTSR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ServerPlaceholder.SecretValue)
$Server = "asazure://westeurope.asazure.windows.net/" + [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ServerPlaceholderBTSR)

$ClientIDPlaceholder = Get-AzKeyVaultSecret -VaultName $KeyVault -Name "ADFClientID"
$ClientIDPlaceholderBTSR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ClientIDPlaceholder.SecretValue)
$ClientID = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ClientIDPlaceholderBTSR)

$ClientSecretPlaceholder = Get-AzKeyVaultSecret -VaultName $KeyVault -Name "ADFClientSecret"
$ClientSecretPlaceholderBTSR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ClientSecretPlaceholder.SecretValue)
$ClientSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ClientSecretPlaceholderBTSR)

$Password = ConvertTo-SecureString $ClientSecret -AsPlainText -Force

$AzurePSCred = New-Object System.Management.Automation.PSCredential ($ClientId,$Password)

write-Output ""
write-Output "======================================================="
write-Output "Done"
write-Output "======================================================="
write-Output ""
write-Output "======================================================="
write-Output "Populating Datasets..."
write-Output "======================================================="
write-Output ""

$DWObjects = Invoke-Sqlcmd -ConnectionString $ConnectionStringDW -Query "SELECT [TableSchema],[TableName],[TableNameCube],[PartitionFromStatement],[ProcessingMode],[IncrementalFact],[MaxModifiedDate] FROM [meta].[SSASProcessing]" -Querytimeout 0

$SSASTablesCommand    = 'SELECT [ModelID],[ID] AS TableID,[Name] AS TableName,[ExcludeFromModelRefresh] FROM $system.TMSCHEMA_TABLES'

$SSASAddPartitionCommand = 'SELECT [TableID],[Name] AS PartitionName,[QueryDefinition],[RefreshedTime]  FROM $system.TMSCHEMA_PARTITIONS WHERE [Name] = ''Add'''

$SSASAllRowsPartitionCommand = 'SELECT [TableID],[Name] AS PartitionName,[QueryDefinition],[RefreshedTime]  FROM $system.TMSCHEMA_PARTITIONS WHERE [Name] <> ''Add'''

## Convert XML to Table ##
[xml]$SSASAllTablesXml = Invoke-ASCmd -Server $Server -Database $ModelName -ServicePrincipal -Credential $AzurePSCred -Query $SSASTablesCommand

[xml]$SSASAddPartitionsXml = Invoke-ASCmd -Server $Server -Database $ModelName -ServicePrincipal -Credential $AzurePSCred -Query $SSASAddPartitionCommand

[xml]$SSASAllRowsPartitionsXml = Invoke-ASCmd -Server $Server -Database $ModelName -ServicePrincipal -Credential $AzurePSCred -Query $SSASAllRowsPartitionCommand

write-Output ""
write-Output "======================================================="
write-Output "Done"
write-Output "======================================================="

########################################################################################
#Truncate temp tables when initiating a full process in order to prevent doublets
########################################################################################

write-Output ""
write-Output "======================================================="
write-Output "Truncating Tables..."
write-Output "======================================================="
write-Output ""

foreach ($so in $DWObjects | where {($_.IncrementalFact -eq 1) } ) {
    
    if ($so.ProcessingMode -eq 'full' -or $JobIsIncremental -eq 0 -or ($JobIsIncremental -eq 1 -and $CleanUpPartitions -eq 1))  {
    $Query = "TRUNCATE TABLE fact." + $so.TableName + '_Temp'

    Invoke-Sqlcmd -ConnectionString $ConnectionStringDW -Query $Query

        }
    }

write-Output ""
write-Output "======================================================="
write-Output "Done"
write-Output "======================================================="
    
########################################################################################
#Create JSON processing script
########################################################################################

write-Output ""
write-Output "======================================================="
write-Output "Creating Json..."
write-Output "======================================================="
write-Output ""

########################################################################################
#Full process database
########################################################################################

if (($JobIsIncremental -eq 0) -or ($JobIsIncremental -eq 1 -and $CleanUpPartitions -eq 1))
    {
        
        $QueryFull = '{
                  "refresh": {
                    "type": "full",
                    "objects": [
                      {
                        "database": "' + $ModelName + '"
                    }
                    ]
                  }
                }'
    }

########################################################################################
#Incremental process database. Only tables where has been updated in DW is processed
########################################################################################


if ($JobIsIncremental -eq 1 -and $CleanUpPartitions -eq 0)
    {

   
        $PlaceholderAdd = ""
        $QueryObjectsAdd = ""
        $CounterAdd = 1

        foreach ($AnalysisServicesTables in $SSASAllTablesXml.Return.Root.Row) {
            
             foreach ($AddPartitions in $SSASAddPartitionsXml.Return.Root.Row | where {$_.TableID -eq $AnalysisServicesTables.TableID }) {

                foreach ($DWObject in $DWObjects | where {$_.ProcessingMode -eq 'add' -and $_.PartitionFromStatement -eq $AddPartitions.QueryDefinition.Replace('SELECT','').Replace('FROM','').Replace('*','').Replace('[','').Replace(']','').Replace('_Temp','').Replace(' ','').Trim() -and $_.MaxModifiedDate -gt $AddPartitions.RefreshedTime }) {
                   
                         $Comma = if($CounterAdd -eq 1) {""} else {","} 
                         $PlaceholderAdd = 
                                        $Comma + 
                                        '{
                                          "database": "' + $ModelName + '",
                                          "table": "' + $AnalysisServicesTables.TableName + '",
                                          "partition": "Add"
                                        }'
                                        
                         $QueryObjectsAdd = $QueryObjectsAdd + $PlaceholderAdd
                         $CounterAdd = $CounterAdd + 1
                      
                                }
                    
                            }
    

                    $QueryAdd = if ($QueryObjectsAdd -ne '') {'{
                                  "refresh": {
                                    "type": "add",
                                    "objects": [' + $QueryObjectsAdd + 
                                    ']
                                    }
                                    }'
                                 }


        }

        $PlaceholderFull = ""
        $QueryObjectsFull = ""
        $PlaceholderCalculatedFull = ""
        $QueryObjectsCalculatedFull = ""
        $PlaceholderRestFull = ""
        $QueryObjectsRestFull = ""
        $CounterFull = 1
        $CounterFullRest = 1
        $CounterFullCalculated = 1

      
           foreach ($AnalysisServicesTables in $SSASAllTablesXml.Return.Root.Row)  {

       
              foreach ($FullPartitions in $SSASAllRowsPartitionsXml.Return.Root.Row | where {$_.TableID -eq $AnalysisServicesTables.TableID -and $_.QueryDefinition -ne $null -and $AnalysisServicesTables.TableName -ne 'Global Measures'}) {

                  foreach ($DWObject in $DWObjects | where {$_.ProcessingMode -eq 'full' -and $_.PartitionFromStatement -eq $FullPartitions.QueryDefinition.Replace('SELECT','').Replace('FROM','').Replace('*','').Replace('[','').Replace(']','').Replace('_Temp','').Replace(' ','').Trim() -and $_.MaxModifiedDate -gt $FullPartitions.RefreshedTime }) {
                         $Comma = if($CounterFull -eq 1) {""} else {","} 
                         $PlaceholderFull = $Comma + 
                                        '{
                                          "database": "' + $ModelName + '",
                                          "table": "' + $AnalysisServicesTables.TableName + '"
                                        }'
                         $QueryObjectsFull = $QueryObjectsFull + $PlaceholderFull
                         $CounterFull = $CounterFull + 1
                            
                            }
                           
                       

              foreach ($FullPartitions in $SSASAllRowsPartitionsXml.Return.Root.Row | where {$_.TableID -eq $AnalysisServicesTables.TableID -and $_.QueryDefinition -ne $null -and $AnalysisServicesTables.TableName -ne 'Global Measures' -and $FullPartitions.QueryDefinition.Replace('SELECT','').Replace('FROM','').Replace('*','').Replace('[','').Replace(']','').Replace('_Temp','').Replace(' ','').Trim() -notin $DWObjects.PartitionFromStatement }) {
                       $Comma = if($CounterFull -ne 1 -and $CounterFullRest -eq 1) {""} else {","} 
                       $PlaceholderRestFull =
                                        $Comma + 
                                        '{
                                          "database": "' + $ModelName + '",
                                          "table": "' + $AnalysisServicesTables.TableName + '"
                                        }'
              
                    
                        $QueryObjectsRestFull = $QueryObjectsRestFull + $PlaceholderRestFull
                        $CounterFullRest = $CounterFullRest + 1
                                      
                        }
                      }               
  
                
         
              foreach ($FullPartitionsCalculated in $SSASAllRowsPartitionsXml.Return.Root.Row | where {$_.TableID -eq $AnalysisServicesTables.TableID -and ($_.QueryDefinition -eq $null -or $AnalysisServicesTables.TableName -eq 'Global Measures')}) {
                        $Comma = if($QueryObjectsFull -eq "" -and $QueryObjectsRestFull -eq "" -and $CounterFullCalculated -eq 1) {""} else {","}
                        $PlaceholderCalculatedFull =
                                        $Comma + 
                                        '{
                                          "database": "' + $ModelName + '",
                                          "table": "' + $AnalysisServicesTables.TableName + '"
                                        }'
              
                    
                        $QueryObjectsCalculatedFull = $QueryObjectsCalculatedFull + $PlaceholderCalculatedFull
                        $CounterFullCalculated = $CounterFullCalculated + 1
                
                        }
                    }

                    $QueryObjectsFullCleansed           = if ($QueryObjectsFull -eq $null -or $QueryObjectsFull -eq '') {''} else {$QueryObjectsFull.Substring(1)}

                    $QueryObjectsRestFullCleansed       = if ($QueryObjectsFullCleansed -eq '' -and ($QueryObjectsRestFull -ne $null -or $QueryObjectsRestFull -ne '')) {$QueryObjectsRestFull.Substring(1)} else {$QueryObjectsRestFull}

                    $QueryObjectsCalculatedFullCleansed = if ($QueryObjectsFullCleansed -eq '' -and ($QueryObjectsRestFull -eq $null -or $QueryObjectsRestFull -eq '')) {$QueryObjectsCalculatedFull.Substring(1)} else {$QueryObjectsCalculatedFull}


                    $QueryFull = '{
                                  "refresh": {
                                    "type": "full",
                                    "objects": [' + $QueryObjectsFullCleansed + $QueryObjectsRestFullCleansed + $QueryObjectsCalculatedFullCleansed +
                                    ']
                                  }
                                }'

    }
                    
write-Output ""
write-Output "======================================================="
write-Output "Done"
write-Output "======================================================="

########################################################################################
#Process Cube
########################################################################################

write-Output ""
write-Output "======================================================="
write-Output "Processing Tabular Model..."
write-Output "======================================================="
write-Output ""      

$ModelUpdateStartTime = get-date

        $ssasMessageFull = Invoke-ASCmd -Server $Server -ServicePrincipal -Credential $AzurePSCred -Query $QueryFull -WarningVariable CapturedWarning
    
if ($QueryAdd -eq $null) {write-output 'No Add Block'} elseif ($JobIsIncremental -eq 1 -and $CleanUpPartitions -eq 0)
    {
        $ssasMessageAdd  = Invoke-ASCmd -Server $Server -ServicePrincipal -Credential $AzurePSCred -Query $QueryAdd -WarningVariable CapturedWarning
    }

$ModelUpdateEndTime = get-date

Write-Output $QueryAdd
Write-Output $QueryFull

write-Output ""
write-Output "======================================================="
write-Output "Done"
write-Output "======================================================="
write-Output ""

########################################################################################
#Update Last Refresh Meta Table
########################################################################################

write-Output ""
write-Output "======================================================="
write-Output "Update Meta Table with Last Refresh..."
write-Output "======================================================="
write-Output ""    

$Query = 'EXEC [meta].[SSASLastValueLoaded] ''' + $ModelName + ''',''' +  $ModelUpdateStartTime + ''',''' + $ModelUpdateEndTime + ''''
Invoke-Sqlcmd -ConnectionString $ConnectionStringDW -Query $Query

$SSASQuery  = '{
                "refresh": {
                            "type": "full",
                            "objects": [
                                {
                                "database": "Wrist Analytics",
                                "table": "Model Update Information"
                                }
                                ,{
                                  "database": "Wrist Analytics",
                                  "table": "Invoice Transactions",
                                  "partition":"Non Invoiced"
                                  }
                            ]
                        }
                }'

Invoke-ASCmd -Server $Server -ServicePrincipal -Credential $AzurePSCred -Query $SSASQuery -WarningVariable CapturedWarning

write-Output ""
write-Output "======================================================="
write-Output "Done"
write-Output "======================================================="
write-Output ""

#####################################################################
# POST HTTP Call to ADF with errors
$ErrorCount = $error.Count + $CapturedWarning.Count
if ($ssasMessageFull -like '*failed*' -or $ssasMessageAdd -like '*failed*') {$ErrorCount += 1}

if ($ErrorCount) 
{
    $Output = [ordered]@{ 
        error = @{
            ErrorCode = "ResizeError"
            Message = $ssasMessageFull + $ssasMessageAdd
        }
        statusCode = "500"
    }
} else {
    $Output = [ordered]@{
            output = @{
                 Message = $ssasMessageFull + $ssasMessageAdd 
                  }
         statusCode = "200"
            }
     }


$body = $Output | ConvertTo-Json #-Depth 10

Invoke-WebRequest -Method 'POST' -Uri $uri -UseBasicParsing -Body $body  -ContentType "application/json" | Out-Null
#####################################################################
      
