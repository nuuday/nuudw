#Parameters
param(

[Parameter(Mandatory=$true)][string]$TargetServerName,
[Parameter(Mandatory=$true)][string]$TargetFolderName
)

#Variables
$SSISNamespace = "Microsoft.SqlServer.Management.IntegrationServices"

# Path of the currently execute script
$ProjectFilePath = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent

Write-Host "Current work path: $ProjectFilePath" 

# Load the IntegrationServices assembly
$loadStatus = [System.Reflection.Assembly]::Load("Microsoft.SQLServer.Management.IntegrationServices, "+
    "Version=14.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91, processorArchitecture=MSIL")

# Create a connection to the server
$sqlConnectionString = `
    "Data Source=" + $TargetServerName + ";Initial Catalog=master;Integrated Security=SSPI;"
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection $sqlConnectionString

# Create the Integration Services object
$integrationServices = New-Object $SSISNamespace".IntegrationServices" $sqlConnection

# Get the Integration Services catalog
$catalog = $integrationServices.Catalogs["SSISDB"]

# Create the target folder

# Script to determine if the SSIS folder is already created
Write-Host "Check if catalog folder ($TargetFolderName)  is created"

	$folder = $catalog.Folders[$TargetFolderName]

if (!$Folder) 
{
	# The folder is not in place and therefore it is being created
    Write-Host "Catalog ($TargetFolderName) is not created and thefore it is being created"
	
    $folder = New-Object $SSISNamespace".CatalogFolder" ($catalog, $TargetFolderName,
        "Folder description")
    $folder.Create()
    
}
ELSE 
{
    Write-Host "Catalog ($TargetFolderName) was in place and therefore this step is skipped"
}


Get-ChildItem -Path (Get-Location) -Filter *.ispac -Recurse -File -Name| ForEach-Object {
	Write-Host "#######################################"
	Write-Host "# Deployment started for:"
	Write-Host "# isPac file:                 "$_.Substring($_.lastIndexOf('\') + 1 ,$_.Length - $_.lastIndexOf('\')-1)
	Write-Host "#"
	Write-Host "# Instance:                   $TargetServerName"
	Write-Host "# Catalog:                    $catalog"
	Write-Host "# Folder:                     $TargetFolderName"
	Write-Host "#"
   
        $ProjectFilePath = ".\$_"
	        
	# Read the project file and deploy it
    [byte[]] $projectFile = [System.IO.File]::ReadAllBytes($ProjectFilePath)
    $folder.DeployProject($_.Substring($_.lastIndexOf('\') + 1 ,$_.Length - $_.lastIndexOf('\')-1).Replace(".ispac",""), $projectFile)

	Write-Host "#"
	Write-Host "# deployment Completed"
	Write-Host "#######################################"
}

Get-Location

