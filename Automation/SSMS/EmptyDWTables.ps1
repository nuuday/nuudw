param (
    [Parameter(Mandatory=$true)][string]$ConnectionString,
    [Parameter(Mandatory=$true)][string]$Execute
)
 


# =====================
# Empty Tables
# =====================

$ExecuteBool = if ($Execute -eq "true") {1} else {0} 

Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "EXECUTE [meta].[EmptyDWTables] @Execute = $($ExecuteBool)"
