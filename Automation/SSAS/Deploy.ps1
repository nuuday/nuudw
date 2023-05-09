param (
    [Parameter(Mandatory=$true)][string]$ModelName,
    [Parameter(Mandatory=$true)][string]$SSASServer,
    [Parameter][string]$RunJob
)
 

# Path of the currently execute script
$path = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent
 
Write-Host "Current work path: $path"
 
# Concatenation of current path and module name
$CMD = [System.IO.Path]::Combine($path,"TabularEditor.exe")
Write-Host $CMD
 
#Source file used for deployment
$arg1 = '"model.bim"'
Write-Host $arg1
 
## Setting deployment name
$arg2 = '-D ' + $SSASServer +' "' + $ModelName + '"'
Write-Host $arg2
 
#Ensuring that errors and warnings are outputtet in a format transparent for the VSTS build engine
$arg3 = '-v -O -C -R -P -M'
Write-Host $arg3
 
cmd /c "$CMD $arg1 $arg2 $arg3"
 