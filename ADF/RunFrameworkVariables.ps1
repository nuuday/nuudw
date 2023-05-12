Import-Module newtonsoft.json
Import-Module Az.Accounts
Import-Module Az.KeyVault
Import-Module sqlserver

# =====================
# START : Variables to set
# =====================
# The tenant ID for the Azure environment
$AzureTenantID = 'c95a25de-f20a-4216-bc84-99694442c1b5';
# The subscription ID for the Azure environment
$AzureSubscriptionID = '155e9e90-807a-43a9-811b-8f7bdb95a801';
# The name of the keyvault to use for getting secrets
$AzureKeyvaultName = 'nuudw-kv01-dev'
# The name of the secret for the connection string to the DW being build
$DWConnectionSecretName = 'ConnectionString-Deployment'
# =====================
# END : Variables to set
# =====================

Write-Host "Check for access ... " -NoNewline
$output = Get-AzAccessToken -TenantId $AzureTenantID
if (!$output) {
    Write-Host "NO ACCESS...." -ForegroundColor Red 
	Write-Host "Signing in to Azure ... " -NoNewline
    Connect-AzAccount -Tenant $AzureTenantID -SubscriptionId $AzureSubscriptionID
}
Write-Host "Done" -ForegroundColor Green

Write-Host "Getting current context if any ... " -NoNewline
$context = Get-AzContext
# =====================
# Login i Azure
# =====================
if (! $context -or ($context.Subscription.Id -ne $AzureSubscriptionID)) {
    Write-Host "no context found - Signing in to Azure ... " -NoNewline
    Connect-AzAccount -Tenant $AzureTenantID -SubscriptionId $AzureSubscriptionID
}
Write-Host "Done" -ForegroundColor Green

$context = Get-AzContext
#check if login was successfull
if (! $context -or ($context.Subscription.Id -ne $AzureSubscriptionID)) {
    Write-Host "Cannot sign into Tenant $($AzureTenantID)" -ForegroundColor Red
    exit
}
# Set-AzContext -Tenant $AzureTenantID -Subscription $AzureSubscriptionID

# The destination path of the .json-files
Write-Host "Setting path for ADF directory ... " -NoNewline
$ADFPath = (Get-Item -Path ".\").FullName + '\';
Write-Host "Done" -ForegroundColor Green

$kvvers = (Get-Module -Name Az.KeyVault).Version

# The connectionstring for the Azure SQL DB
if ( (($kvvers.Major[0]) -as [int] -lt 3) -or (($kvvers.Major[0]) -as [int] -eq 3 -and ($kvvers.Minor[0]) -as [int] -lt 3) ) { 
	# Get sql password from Key Vault
    $Secret = (Get-AzKeyVaultSecret -VaultName $AzureKeyvaultName -Name $DWConnectionSecretName).SecretValue 
    $Secret
    # The way to extract plain text information from a secret in Azure Key Vault has changed when using powershell 7
    if ($PSVersionTable.PSVersion.Major -as [int] -le 5) {
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Secret)
        $ConnectionString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    }
    else {
	    $ConnectionString = $Secret | ConvertFrom-SecureString -AsPlainText
    }
}
else {
	$ConnectionString = Get-AzKeyVaultSecret -VaultName $AzureKeyvaultName -Name $DWConnectionSecretName -AsPlainText
}

if ($ConnectionString -eq "") {
    Write-Host "No connection string to Datawarehouse DB found" -ForegroundColor Red
    exit
}

Write-Host "User ($($context.Account)) is connected to subscription ($($context.Subscription.Name))"
