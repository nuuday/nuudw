# Load security protocol to handle HTTPS connection to GitHub
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Load Github release details for Tabular Editor
$TabularEditor = Invoke-WebRequest -Uri "http://api.github.com/repos/otykier/TabularEditor/releases/14408686" | ConvertFrom-Json;

# Identify download path from for TabularEditor.zip for download purposes
$TabularEditorDownloadPath = $TabularEditor.Assets | Where-Object { $_.name -eq "TabularEditor.zip" }  | Select-Object @{N="DownloadPath";E={$_.browser_download_url }} 

# Download file to root of repository
$TabularEditorZip = join-path (get-location) "TabularEditor.zip"
Invoke-WebRequest -Uri $TabularEditorDownloadPath.DownloadPath -OutFile $TabularEditorZip

#Unzip and delete archive
Write-Host "Expanding archive to " + (get-location).Path
Expand-Archive -Path $TabularEditorZip -DestinationPath  (get-location).Path
Remove-Item $TabularEditorZip

# Install AMO package to Tabular Editor to run
# Make sure we have Nuget.exe
$nugetFolder = Join-Path $env:LOCALAPPDATA "Nuget"

$nugetExe = Join-Path $nugetFolder "Nuget.exe"

if (-not (Test-Path $nugetFolder)) { 
    New-Item $nugetFolder -ItemType Directory
}

if (-not (Test-Path $nugetExe)) {
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile $nugetExe
}

& $nugetExe update -self

# Download AMO Libraries
$nugetExe = [System.IO.Path]::Combine($Env:LOCALAPPDATA, "Nuget", "Nuget.exe")
& $nugetExe install Microsoft.AnalysisServices.retail.amd64 -OutputDirectory (get-location) -ExcludeVersion

# Move AMO DLL's to Tabular Editor for it to run
$AMOFilePath = Join-Path (get-location) "Microsoft.AnalysisServices.retail.amd64\lib\net45"
Write-Host "Moving AMO files from $AMOFilePath to " (get-location).Path
Move-Item -Path "$AMOFilePath\*" -Destination (get-location)