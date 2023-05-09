param (
    [Parameter(Mandatory=$true)][string]$Configuration,
    [string]$DeploymentProtectionLevel,
    [String]$BuildDefinitionName
    )

New-Item -ItemType Directory -Force -Path .\build

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

# Download SSISBuild
$nugetExe = [System.IO.Path]::Combine($Env:LOCALAPPDATA, "Nuget", "Nuget.exe")
& $nugetExe install SSISBuild -OutputDirectory "packages" -ExcludeVersion

# Import SSISBuild Modules
Import-Module .\packages\SSISBuild\tools\SsisBuild.Core.dll
Import-Module .\packages\SSISBuild\tools\SsisBuild.Logger.dll


$ProjectFilePath = [System.IO.Path]::Combine((Get-Location).Path,$BuildDefinitionNamE,$projectFileName)

## OUtput project file filepath
Write-Host $ProjectFilePath

# Search for All SSIS projects and build this without considering specific path
# This is intended to make the approach more generic
Get-ChildItem -Path (Get-Location).Path -Filter *.dtproj -Recurse -File -Name| ForEach-Object {
	$dtprodPath = [System.IO.Path]::Combine((Get-Location).Path,$_);
	New-SsisDeploymentPackage $dtprodPath  -ProtectionLevel $DeploymentProtectionLevel -Configuration $Configuration -OutputFolder .\Build\  -Parameters @{}#"Project::SourceDBServer" = $SourceDBServer; "Project::SourceDBName" = $SourceDBName}    
}