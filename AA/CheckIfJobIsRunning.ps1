param(
[Parameter (Mandatory = $false)][object] $WebhookData
)

#####################################################################
# ADF POST HTTP Call information
$body = (ConvertFrom-Json -InputObject $WebhookData.RequestBody)
$uri = $body.callBackUri
$KeyVault = $body.parameters.KeyVault 
$DataFactoryName = $body.parameters.DataFactoryName
$CurrentRunID = $body.parameters.CurrentRunID
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
write-Output ""
write-Output "======================================================="
write-Output "Getting Secrets from KeyVault..."
write-Output "======================================================="
write-Output ""

$ResourceGroupNamePlaceholder = Get-AzKeyVaultSecret -VaultName $KeyVault -Name "ADFResourceGroupName"
$PlaceholderResourceGroupNameBSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ResourceGroupNamePlaceholder.SecretValue)
$ResourceGroupName = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($PlaceholderResourceGroupNameBSTR)

write-Output ""
write-Output "======================================================="
write-Output "Done"
write-Output "======================================================="
write-Output ""
Write-Output ""
Write-Output "======================================================="
Write-Output "Checking if important pipelines are currently running"
Write-Output "======================================================="
Write-Output ""

$before = get-date
$after = (get-date).AddHours(-10)


$runIds = Get-AzDataFactoryV2PipelineRun -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -LastUpdatedAfter $after -LastUpdatedBefore $before

$ProcessingFlag = 0

foreach($row in $runIds | where {$_.PipelineName -like 'Load DW*' -and $_.RunID -ne $CurrentRunID}) {
    ## Check for all statuses
    if($row.Status -eq "InProgress"){
        $ProcessingFlag = 1
    }

}

$Output = [ordered]@{ 
        output = @{
                ProcessingFlag = $ProcessingFlag
                  }
         statusCode = "200"
        }

write-Output ""
write-Output "======================================================="
write-Output "Done"
write-Output "======================================================="
write-Output ""

#####################################################################
# ADF POST HTTP Call information
$body =  $Output | ConvertTo-Json #-Depth 10

Invoke-WebRequest -Method 'POST' -Uri $uri -UseBasicParsing -Body $body -ContentType "application/json" | Out-Null
#####################################################################

