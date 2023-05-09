param (
    [Parameter(Mandatory = $true)][string] $artifactsFolder,
    [Parameter(Mandatory = $true)][string] $ResourceGroupName,
    [Parameter(Mandatory = $true)][string] $AutomationAccountName,
    [Parameter(Mandatory = $true)][string] $ChangesPathFilter,
    [Parameter(Mandatory = $true)][string] $keyvaultName
)

################################################################################################################
# Functions
################################################################################################################

function Import-AARunbook {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)] $File,
        [Parameter(Mandatory=$true)][string] $AutomationAccountName,
        [Parameter(Mandatory=$true)][string] $ResourceGroupName,
        [Parameter(Mandatory = $true)][string] $keyvaultName
    )
    process {
        Write-Host "Syncing $($File.FullName)"
        $AST = [System.Management.Automation.Language.Parser]::ParseFile($File.FullName, [ref]$null, [ref]$null);
        if ($AST.EndBlock.Extent.Text.ToLower().StartsWith("workflow")) {
            Write-Verbose "File is a PowerShell workflow"
            Import-AzAutomationRunbook -Path $File.FullName -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName -Type PowerShellWorkflow -Force -Published
        } elseif ($AST.EndBlock.Extent.Text.ToLower().StartsWith("configuration")) {
            Write-Verbose "File is a configuration script"
            Import-AzAutomationDscConfiguration -Path $File.FullName -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName -Force -Published
        } else {
            Write-Verbose "File is a powershell script"

            # Import runbook
            $RunBook = Import-AzAutomationRunbook -Path $File.FullName -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName -Type PowerShell -Force -Published

            # Create webhook
            $webhookName = "Webhook-$($RunBook.Name -replace "_", "-")"
            $ExpiryDate = (Get-Date).AddYears(2)

            # First check for (and delete) existing webhooks
            $existingWebhooks = Get-AzAutomationWebhook -RunbookName "$($RunBook.Name)" -ResourceGroup $ResourceGroupName -AutomationAccountName $AutomationAccountName
            $existingWebhooks | ForEach-Object {
                if($_.Name -eq $webhookName) {
                    # We need to delete existing one to be able to create new one
                    Remove-AzAutomationWebhook -Name $_.Name -ResourceGroup $ResourceGroupName -AutomationAccountName $AutomationAccountName
                }
            }

            #$ParamString = "ENVIRONMENT=$Environment" 

               #Convert Parameters into Hash Table
            #$ParamHash = ConvertFrom-StringData -StringData $ParamString

            # Now create the webhook
            $Webhook = New-AzAutomationWebhook -Name $webhookName -IsEnabled $True -RunbookName "$($RunBook.Name)" -ExpiryTime $ExpiryDate -ResourceGroup $ResourceGroupName -AutomationAccountName $AutomationAccountName -Force

            # Create secret in KeyVault referencing webhook URI
            $webhookURI = ConvertTo-SecureString -String $Webhook.WebhookURI -AsPlainText -Force
            $secret = Set-AzKeyVaultSecret -VaultName $keyvaultName -Name $webhookName -SecretValue $webhookURI -ContentType "RunbookWebhook"
        }
    }
}

################################################################################################################
# Script
################################################################################################################

# Write to log
Write-Host "Deploying Azure Automation to Resource Group: $($ResourceGroupName)"
Write-Host "Deploying to Automation Account Name: $($AutomationAccountName)"

# Get all runbooks in artifact
$AllRunbooks = Get-ChildItem -Path ( Join-Path $artifactsFolder $ChangesPathFilter ) -Recurse | Where-Object { $_.Extension -eq ".ps1" }

# Import all runbooks
$AllRunbooks | Import-AARunbook -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroupName -keyvaultName $keyvaultName