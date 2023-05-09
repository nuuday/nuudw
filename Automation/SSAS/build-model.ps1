param (
    [Parameter(Mandatory = $true)][string]$ModelName,
    [Parameter(Mandatory = $false)][string]$scriptFile
    # TODO: Support validation towards tabular instance
    #[Parameter(Mandatory=$true)][string]$SSASServer
)



## Available in root path based on standard install script for hosted instance
$TabularEditorPath = (Join-path -Path (get-location).Path -ChildPath "Tools\TabularEditor\TabularEditor.exe")
Move-Item -Path "$TabularEditorPath" -Destination (get-location)
$CMD = (Join-path -Path (get-location).Path -ChildPath "TabularEditor.exe")

Write-Host $CMD

#Source folder used for deployment
$SSASPath = (Join-path -Path (get-location).Path -ChildPath "SSAS")
$arg1 = (Join-Path -Path $SSASPath -ChildPath $ModelName )
$arg1 = "`"$arg1`""
Write-Host $arg1

# Include script file if it has been specified
if ($scriptFile -ne "") {

    #File used for customer build of model for country
    $arg2 = '-S "' + $scriptFile + '"'
    Write-Host $arg2

}

#File which should be outputted
$buildDefinitionBIM = '"model.bim"'
$arg3 = '-B ' + $buildDefinitionBIM
Write-Host $arg3

#Ensuring that errors and warnings are outputtet in a format transparent for the VSTS build engine
$arg4 = '-v'
Write-Host $arg4

## Build new file4
Write-Host "Full command:"
Write-Host "$CMD $arg1 $arg2 $arg3 $arg4"
cmd /c "$CMD $arg1 $arg2 $arg3 $arg4"

Write-Host "Build completed..."


## Prepare for deployment
## TODO: Ensure that model is deployed to tabular server and processed
# $randomName = [guid]::NewGuid().ToString();

## Settings source for deployment
#$arg1 = $buildDefinitionBIM

## Setting deployment name
#$arg2 = '-D ' + $SSASServer + ' "' + $randomName + '"'

#Ensuring that errors and warnings are outputtet in a format transparent for the VSTS build engine
#$arg3 = '-v -O -C -R -P -M'

#cmd /c "$CMD $arg1 $arg2 $arg3"

## PRocess recalc to return issues on processing
# Environment definitions

#$TABULAR_SERVER = $SSASServer
#$TABULAR_DATABASE = $randomName

# Connect to model

#[Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices");
#[Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices.Core");
#[Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices.Tabular");
#$as = New-Object Microsoft.AnalysisServices.Server
#$as.connect($TABULAR_SERVER)
#$db = $as.databases[$TABULAR_DATABASE]

# Update model
# [Microsoft.AnalysisServices.ProcessType]::ProcessClear
#$db.Drop()

#$as.Disconnect()
