param (
    [Parameter(Mandatory=$true)][string]$ResourceGroup,
    [Parameter(Mandatory=$true)][string]$SSASServer
)
 



$asSrv = Get-AzAnalysisServicesServer -Name $SSASServer -ResourceGroupName $ResourceGroup -ErrorAction SilentlyContinue

    if($asSrv.State -ne "Paused")
    {
        Write-Output "Server is online. Pausing!"
        $asSrv | Suspend-AzAnalysisServicesServer -WarningVariable CapturedWarning
        Write-Output "Server Paused."
    }
    if($asSrv.State -eq "Paused")
    {
        Write-Output "Server is already paused!"
    }

    