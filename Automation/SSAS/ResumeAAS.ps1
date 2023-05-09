param (
    [Parameter(Mandatory=$true)][string]$ResourceGroup,
    [Parameter(Mandatory=$true)][string]$SSASServer
)
 



$asSrv = Get-AzAnalysisServicesServer -Name $SSASServer -ResourceGroupName $ResourceGroup


        if($asSrv.State -eq "Paused")
        {
            Write-Output "Server is paused. Resuming!"
            $asSrv | Resume-AzAnalysisServicesServer -WarningVariable CapturedWarning
            Write-Output "Server Resumed."
        }
        if($asSrv.State -ne "Paused")
        {
            Write-Output "Server is already online!"
        }
      