param (
    [Parameter(Mandatory = $true)][string]$ModelName,
    [Parameter(Mandatory = $false)][string]$scriptFile
)

## Available in root path based on standard install script for hosted instance
$CMD = (get-location).path + '\TabularEditor.exe'
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