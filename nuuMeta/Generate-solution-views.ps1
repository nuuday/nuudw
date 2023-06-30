Param(
    [Parameter(Position=0,Mandatory=$true)]
    [string]$SolutionAbbreviation
)

$ErrorActionPreference = "Stop"

#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# =====================
# Check installed modules
# =====================

$requiredModules = @("sqlserver")

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

[Reflection.Assembly]::LoadWithPartialName("Newtonsoft.Json.dll")


# =====================
# Login i Azure
# =====================

#Connect-AzAccount -TenantId "c95a25de-f20a-4216-bc84-99694442c1b5" -SubscriptionId "155e9e90-807a-43a9-811b-8f7bdb95a801"

# The connectionstring for the Azure SQL DB
$ConnectionString = Get-AzKeyVaultSecret -VaultName "nuudw-kv01-dev" -Name "ConnectionString-nuudwsqldb01" -AsPlainText
$KeyVaultPrefix = Get-AzKeyVaultSecret -VaultName "nuudw-kv01-dev" -Name "KeyVaultPrefix"


# =====================
# Datasets
# =====================

Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "EXEC nuuMeta.MaintainDWCreateCubeViews @Solution ='$($SolutionAbbreviation)'"

Write-Host "Views for $($SolutionAbbreviation) were created" -ForegroundColor Green  -NoNewline
