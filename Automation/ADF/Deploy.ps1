param (
    [Parameter(Mandatory = $true)][string]$ResourceGroupName,
    [Parameter(Mandatory = $true)][string]$DataFactoryName,
    [Parameter(Mandatory = $true)][string]$IntegrationRuntimeName,
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$SubscriptionID,
    [Parameter(Mandatory = $false)][string]$ConnectionReplacements = '',
    [Parameter(Mandatory = $false)][string]$TriggerReplacements = '',
    [Parameter(Mandatory = $true)][string]$TenantId
)


################################################################################################################
# Functions
################################################################################################################

function WriteHeader ([String] $headerText) {
    Write-Host ""
    Write-Host "################################################################################################################" -ForegroundColor Yellow
    Write-Host "# $($headerText)" -ForegroundColor Yellow
    Write-Host "################################################################################################################" -ForegroundColor Yellow
    Write-Host ""
}

function Get-ChildActivities {
    Param(
        $obj,
        [string] $ActivityType
    )

    $references = @()

    if ($obj.PSObject.Properties.name -contains "properties") {
        if ($obj.properties.PSObject.Properties.name -match "activities") {
            $references += Get-ChildActivities -obj $obj.properties -ActivityType $ActivityType
        }
    }

    $activities = $null

    if ($obj.PSObject.Properties.name -contains "activities") {
        $activities = $obj.activities
    } elseif ($obj.PSObject.Properties.name -contains "ifTrueActivities") {
        $activities = $obj.ifTrueActivities
    }

    if ($activities -eq $null) {
        return $references
    }

    $activities | ForEach-Object {
        if ( $_.type -eq $ActivityType ) {
            $references += $_
        } elseif ($_.PSObject.Properties.name -contains "typeProperties") {
            if ($_.typeProperties.PSObject.Properties.name -match "activities") {
                $references += Get-ChildActivities -obj $_.typeProperties -ActivityType $ActivityType
            }
        }
    }

    return $references
}

function Merge-Json {
    param (
        [PSCustomObject]$base,
        [PSCustomObject]$changes
    )
    $merged = $base.PsObject.Copy()
    $changes.PSObject.Properties | ForEach-Object {
        if ($_.TypeNameOfValue -eq 'System.Management.Automation.PSCustomObject' -and $merged."$($_.Name)" ) {
            $merged."$($_.Name)" = Merge-Json $merged."$($_.Name)" $_.Value
        } else {
            if ($merged."$($_.Name)") {
                if ($merged."$($_.Name)" -ne $_.Value) {
                    Write-Host "Updating property: $($_.Name)"
                    $merged | Add-Member -MemberType $_.MemberType -Name $_.Name -Value $_.Value -Force
                }
            } else {
                Write-Host "Adding property: $($_.Name)"
                $merged | Add-Member -MemberType $_.MemberType -Name $_.Name -Value $_.Value -Force
            }
        }
    }
    return $merged
}

################################################################################################################
# Initialization
################################################################################################################

# Get deployed linked services and validate with branch
WriteHeader "Initializing"
#Import-Module Az

# Select subscription for connecting to Data Factory
#Select-AzSubscription $SubscriptionID | Out-Null

# Get all resources from ADF
$integrationRuntime = Get-AzDataFactoryV2IntegrationRuntime -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName
$linkedServices = Get-AzDataFactoryV2LinkedService -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName
$pipelines = GET-AzDataFactoryV2Pipeline -ResourceGroupName $ResourceGroupName -DataFactoryNAme $DataFactoryName
$datasets = GET-AzDataFactoryV2Dataset -ResourceGroupName $ResourceGroupName -DataFactoryNAme $DataFactoryName
$triggers = Get-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName
$disabledPersistentTriggers = $triggers | Where-Object { $_.RuntimeState -ne 'Started' -and $_.Name -match '^PERSISTENT\s*-' }

# Get all resources from branch
$branchIntegrationRuntime = @()
if (Test-Path -Path "$Path\integrationRuntime") {
    $branchIntegrationRuntime = Get-ChildItem "$Path\integrationRuntime" -Filter *.JSON
}

$branchLinkedServices = @()
if (Test-Path -Path "$Path\linkedService") {
    $branchLinkedServices = Get-ChildItem "$Path\linkedService" -Filter *.JSON
}

$branchPipelines = @()
if (Test-Path -Path "$Path\pipeline") {
    $branchPipelines = Get-ChildItem "$Path\pipeline" -Filter *.JSON
}

$branchDatasets = @()
if (Test-Path -Path "$Path\dataset") {
    $branchDatasets = Get-ChildItem "$Path\dataset" -Filter *.JSON
}

$branchTriggers = @()
if (Test-Path -Path "$Path\trigger") {
    $branchTriggers = Get-ChildItem "$Path\trigger" -Filter *.JSON | Where-Object { $_.Name -notMatch 'DEV_ONLY' }
}

# Get potential replacements objects from json
$ConnectionReplacementsArray = ($ConnectionReplacements | ConvertFrom-Json)
$TriggerReplacementsArray = ($TriggerReplacements | ConvertFrom-Json)

################################################################################################################
# Triggers
################################################################################################################

# Get deployed linked services and validate with branch
WriteHeader "Disabling triggers for the time of release"

# Disable triggers
foreach ( $trigger in $triggers ) {
    Write-Host "Trigger: $($trigger.Name) ... "  -NoNewline
    Stop-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $trigger.Name -Force | Out-Null
    Write-host " Disabled" -foregroundcolor Green
}



################################################################################################################
# Linked Services
################################################################################################################

# Get deployed linked services and validate with branch
WriteHeader "Validating linked services"

# Validate Linked Services from branch
foreach ( $branchLinkedService in $branchLinkedServices )
{
    $branchLinkedServiceName = $branchLinkedService.Name -replace(".json", "")
    write-host "Validating Linked Service from branch: $($branchLinkedServiceName) ... "  -NoNewline

    # Load file content to avoid deploying Key Vaults
    $branchLinkedServiceDefinition = Get-Content -Encoding UTF8 -Path $branchLinkedService.FullName | ConvertFrom-Json

    $linkValidated = $true
    $linkExist = $true

    if ($branchLinkedServiceDefinition.properties.type -eq "AzureKeyVault")
    {
        # We don't want to deploy key vaults as they are specific per environmant
        Write-host " Is a Key Vault and will not be deployed" -foregroundcolor Yellow
        continue
    }

     Write-host " - source code definition updated according to target env. Changed: [" -NoNewline
    # If connecting thru IR, we need to update for environment
    if ($branchLinkedServiceDefinition.properties.PSObject.Properties.name -match "connectVia")
    {
        # First manipulate IR
        (Get-Content -Encoding UTF8 $branchLinkedService.FullName).replace($branchLinkedServiceDefinition.properties.connectVia.referenceName , $IntegrationRuntimeName) | Set-Content -Encoding UTF8 $branchLinkedService.FullName
        Write-host " IR" -NoNewline
    }
    if ($ConnectionReplacementsArray | Where-Object { $_.name -eq $branchLinkedServiceName })
    {
        # Some properties needs to be modified for environment
        $ConnectionReplacement = $ConnectionReplacementsArray | Where-Object { $_.name -eq $branchLinkedServiceName }

        if ($ConnectionReplacement.properties.PSObject.Properties.name -match "typeProperties")
        {
            # We need to change something under typeProperties
            if ($ConnectionReplacement.properties.typeProperties.PSObject.Properties.name -match "server")
            {
                # Change server name
                (Get-Content -Encoding UTF8 $branchLinkedService.FullName).replace($branchLinkedServiceDefinition.properties.typeProperties.server, $ConnectionReplacement.properties.typeProperties.server) | Set-Content -Encoding UTF8 $branchLinkedService.FullName
                Write-host " server" -NoNewline
            }
            if ($ConnectionReplacement.properties.typeProperties.PSObject.Properties.name -match "userName")
            {
                # Change user name
                (Get-Content -Encoding UTF8 $branchLinkedService.FullName).replace($branchLinkedServiceDefinition.properties.typeProperties.userName, $ConnectionReplacement.properties.typeProperties.userName) | Set-Content -Encoding UTF8 $branchLinkedService.FullName
                Write-host " userName" -NoNewline
            }
            if ($ConnectionReplacement.properties.typeProperties.PSObject.Properties.name -match "url")
            {
                # Change user name
                (Get-Content -Encoding UTF8 $branchLinkedService.FullName).replace($branchLinkedServiceDefinition.properties.typeProperties.url, $ConnectionReplacement.properties.typeProperties.url) | Set-Content -Encoding UTF8 $branchLinkedService.FullName
                Write-host " url" -NoNewline
            }
        }
    }

    Write-host " ]" -NoNewline

    $branchLinkedServiceDefinition = Get-Content -Encoding UTF8 -Path $branchLinkedService.FullName | ConvertFrom-Json

    if ( $linkedServices | Where-Object { $_.Name -eq $branchLinkedServiceName } )
    {
        # Already exists
        Write-host " Exists" -foregroundcolor Green -NoNewline

        $linkedService = ($linkedServices | Where-Object { $_.Name -eq $branchLinkedServiceName })[0]

        try
        {
            if ($branchLinkedServiceDefinition.properties.PSObject.Properties.name -match "connectVia")
            {
                if ($linkedService.Properties.ConnectVia.referenceName -ne $branchLinkedServiceDefinition.properties.connectVia.referenceName)
                {
                    $linkValidated = $false
                    Write-host " - 'connectVia' param not in sync" -foregroundcolor Red -NoNewline
                }
            }
            if ($branchLinkedServiceDefinition.properties.PSObject.Properties.name -match "typeProperties")
            {
                $typePropertiesObject = ($linkedService.Properties.AdditionalProperties.typeProperties.toString() | ConvertFrom-JSON)
                $branchTypeProperties = $branchLinkedServiceDefinition.properties.typeProperties

                foreach ($propertyToValidate in $branchTypeProperties.PSObject.Properties.Name)
                {
                    $propertyValue = $typePropertiesObject | Select-Object -ExpandProperty $propertyToValidate | Out-String
                    $branchPropertyValue = $branchTypeProperties | Select-Object -ExpandProperty $propertyToValidate | Out-String
                    if (Compare-Object -CaseSensitive -ReferenceObject $propertyValue -DifferenceObject $branchPropertyValue)
                    {
                        $linkValidated = $false
                        Write-host " - 'typeProperties.$($propertyToValidate)' param not in sync" -foregroundcolor Red -NoNewline
                    }
                }
            }
        }
        catch
        {
            $linkValidated = $false
        }

        if ($linkValidated)
        {
            Write-host " - Validated" -foregroundcolor Green
        }
        else
        {
            Write-host " - Invalidated" -foregroundcolor Red -NoNewline
        }
    }
    else
    {
        Write-host " Doesn't exist" -foregroundcolor Red -NoNewline
        $linkExist = $false
    }

    if (-not ($linkValidated -and $linkExist))
    {
        # Deploy
        Write-host " - Deploying" -NoNewline
        Set-AzDataFactoryV2LinkedService -DataFactoryName $DataFactoryName -ResourceGroupName $ResourceGroupName -Name "$($branchLinkedServiceName)" -DefinitionFile $branchLinkedService.FullName | out-null #-Force | out-null
        Write-host " - Deployed" -foregroundcolor Green
    }
}

################################################################################################################
# Datasets
################################################################################################################

# Validate datasets from branch
WriteHeader "Validating datasets from branch"

foreach ( $branchDataset in $branchDatasets )
{
    $branchDatasetName = $branchDataset.Name.ToString() -replace(".json", "")
    write-host "Validating Dataset from branch: $($branchDatasetName) ... "  -NoNewline

    # See if already deployed
    $dataset = $datasets | Where-Object { $_.Name -eq $branchDatasetName }
    if ( $dataset.Count -eq 0 )
    {
        # Doesn't exist - should be deployed
        Write-host " Doesn't exist... Deploying..." -foregroundcolor Yellow -NoNewline
        Set-AzDataFactoryV2Dataset -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name "$($branchDatasetName)" -DefinitionFile $branchDataset.FullName | out-null #-Force | Out-Null
        Write-host " Deployed" -foregroundcolor Green
    }
    else
    {
        # Already exist - we validate if there are any changes
        Write-host " Exists... Validating..." -foregroundcolor Yellow -NoNewline

        $branchDatasetDefinition = Get-Content -Encoding UTF8 -Path $branchDataset.FullName | ConvertFrom-Json
        $datasetDefinition = $dataset | ConvertTo-Json | ConvertFrom-Json

        # First we do a comparison on the structure
        if ( $dataset.Structure -ne $null -and $branchDatasetDefinition.properties.structure -ne $null )
        {
            $structureComparison = Compare-Object -ReferenceObject $branchDatasetDefinition.properties.structure -DifferenceObject ( $dataset.Structure.ToString() | ConvertFrom-Json )
        }
        elseif ( $dataset.Structure -eq $null -and $branchDatasetDefinition.properties.structure -eq $null )
        {
            $structureComparison = $null
        }
        else
        {
            $structureComparison = "Error"
        }

        # Check if same linked service
        if ( $branchDatasetDefinition.properties.linkedServiceName.referenceName -ne $datasetDefinition.Properties.LinkedServiceName.ReferenceName )
        {
            Write-host " Wrong LinkedService - redeploying..." -foregroundcolor Red -NoNewline
            Set-AzDataFactoryV2Dataset -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name "$($branchDatasetName)" -DefinitionFile $branchDataset.FullName | out-null #-Force | Out-Null
            Write-host " Deployed" -foregroundcolor Green
        }
        # Check if same folder
        elseif ( $branchDatasetDefinition.properties.folder.name -ne $datasetDefinition.Properties.folder.name )
        {
            Write-host " Wrong folder - redeploying..." -foregroundcolor Red -NoNewline
            Set-AzDataFactoryV2Dataset -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name "$($branchDatasetName)" -DefinitionFile $branchDataset.FullName | out-null #-Force | Out-Null
            Write-host " Deployed" -foregroundcolor Green
        }
        # Check if changes to ctructure
        elseif ( $structureComparison -ne $null )
        {
            Write-host " Wrong structure - redeploying..." -foregroundcolor Red -NoNewline
            Set-AzDataFactoryV2Dataset -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name "$($branchDatasetName)" -DefinitionFile $branchDataset.FullName | out-null #-Force | Out-Null
            Write-host " Deployed" -foregroundcolor Green
        }
        # Deployed version is correct
        else
        {
            Write-host " Validated" -foregroundcolor Green
        }
    }
}

################################################################################################################
# Pipelines
################################################################################################################

# Validate pipelines from branch
WriteHeader "Validating pipelines from branch"

# First assign sortorder if has child pipelines or not
foreach ($branchPipeline in $branchPipelines )
{
    $branchPipelineDefinition = Get-Content -Encoding UTF8 -Path $branchPipeline.FullName | ConvertFrom-Json
    if (@(Get-ChildActivities -obj $branchPipelineDefinition -ActivityType "ExecutePipeline").count -gt 0)
    {
        #Pipeline is referencing other pipelines - assign 2
        $branchPipeline | Add-Member -NotePropertyName SortOrder -NotePropertyValue 2 -Force
    }
    else
    {
        $branchPipeline | Add-Member -NotePropertyName SortOrder -NotePropertyValue 1 -Force
    }
    $branchPipeline | Add-Member -NotePropertyName Definition -NotePropertyValue $branchPipelineDefinition -Force
}

# Then assign sortorder depending of depth of child pipelines
foreach ($branchPipeline in ($branchPipelines | Where-Object { $_.SortOrder -eq 2 }))
{
    $SortOrder = 2

    foreach ($activity in $branchPipeline.Definition.properties.activities)
    {
        $ChildPipeline = $branchPipelines | Where-Object { $_.Name -eq "$($activity.typeProperties.pipeline.referenceName).json" }

        foreach ( $ChildActivity in $ChildPipeline.Definition.properties.activities | Where-Object { $_.type -eq "ExecutePipeline"} )
        {
            $SortOrder += 1

            $GrandChildPipeline = $branchPipelines | Where-Object { $_.Name -eq "$($ChildActivity.typeProperties.pipeline.referenceName).json" }
            $SortOrder += @($GrandChildPipeline.Definition.properties.activities | Where-Object { $_.type -eq "ExecutePipeline"}).count
        }
    }

    $branchPipeline | Add-Member -NotePropertyName SortOrder -NotePropertyValue $SortOrder -Force
}

# Run run thru all pipelines in branch to deploy
foreach ($branchPipeline in $branchPipelines | Sort-Object SortOrder)
{
    $branchPipelineName = $branchPipeline.Name.ToString() -replace(".json", "")
    write-host "Validating Pipeline from branch: $($branchPipelineName) ... "  -NoNewline

    $Pipeline = $Pipelines | Where-Object { $_.Name -eq $branchPipelineName }
    if ( $Pipeline.Count -eq 0 )
    {
        Write-host " Doesn't exist... Deploying..." -foregroundcolor Yellow -NoNewline
        Set-AzDataFactoryV2Pipeline -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name "$($branchPipelineName)" -DefinitionFile $branchPipeline.FullName -Force | out-null #-Force | Out-Null
        Write-host " Deployed" -foregroundcolor Green
    }
    else
    {
        Write-host " Exists... Redeploying..." -foregroundcolor Yellow -NoNewline
        Set-AzDataFactoryV2Pipeline -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name "$($branchPipelineName)" -DefinitionFile $branchPipeline.FullName -Force | out-null #-Force | Out-Null
        Write-host " Deployed" -foregroundcolor Green
    }
}

################################################################################################################
# Triggers
################################################################################################################
WriteHeader "Validating triggers from branch"

foreach ( $branchTrigger in $branchTriggers ) {
    $branchTriggerDefinition = Get-Content -Encoding UTF8 -Path $branchTrigger.FullName | ConvertFrom-Json
    $triggerReplacement = $TriggerReplacementsArray | Where-Object {$_.name -eq $branchTriggerDefinition.Name}
    if (-not $triggerReplacement) {continue}
    Write-Host "Updating '$($branchTriggerDefinition.name)' trigger definition according to replacements array... "
    $branchTriggerDefinition = Merge-Json -base $branchTriggerDefinition -changes $triggerReplacement
    $branchTriggerDefinition | ConvertTo-Json -Depth 100 | Set-Content -Encoding UTF8 $branchTrigger.FullName
    Write-host " DONE" -foregroundcolor Green
}

foreach ( $branchTrigger in $branchTriggers ) {
    $branchTriggerDefinition = Get-Content -Encoding UTF8 -Path $branchTrigger.FullName | ConvertFrom-Json
    Write-Host "Trigger: $($branchTriggerDefinition.Name) ... " -NoNewline
    Set-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $branchTriggerDefinition.Name -DefinitionFile $branchTrigger.FullName -Force | Out-Null
    $publishedTrigger = $triggers | Where-Object { $_.Name -eq $branchTriggerDefinition.Name }
    if ( $publishedTrigger -eq $null ) {
        Write-host " Deployed" -foregroundcolor Green
    } else {
        Write-host " Redeployed" -foregroundcolor Green
    }
}

################################################################################################################
# Cleanup
################################################################################################################
WriteHeader "Cleanup"

# Remove outdated triggers
WriteHeader "Validating excess triggers in ADF"
$invalidatedTriggers = $triggers
if ($invalidatedTriggers) {
    $invalidatedTriggers = $invalidatedTriggers | Where-Object { $_.Name -notMatch '^PERSISTENT\s*-' }
}
if ($invalidatedTriggers -and $branchTriggers) {
    $invalidatedTriggers = $invalidatedTriggers | Where-Object { $branchTriggers.Name -notContains "$($_.Name).json" }
}

foreach ( $trigger in $invalidatedTriggers ) {
    Write-Host "Trigger: $($trigger.Name) ... "  -NoNewline
    Remove-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $trigger.Name -Force | Out-Null
    Write-host " Removed" -foregroundcolor Green
}

# Check for pipelines that should be removed
WriteHeader "Validating excess pipelines in ADF"

$pipelineCount = $pipelines.Count

while ( $pipelineCount -gt 0 )
{
    foreach ( $pipeline in $pipelines )
    {
        $pipelineName = $pipeline.Name + ".json"

        if ( ($branchPipelines | Where-Object { $_.Name -eq $pipelineName }).Count -eq 0 )
        {
            Write-Host "$($pipeline.Name) doesn't exist in branch, and will be removed..." -NoNewline
            try
            {
                Remove-AzDataFactoryV2Pipeline -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name "$($pipeline.Name)" -Force | Out-Null
                Write-Host " Removed..." -ForegroundColor Green
                $pipelineCount -= 1
            }
            catch
            {
            Write-Host " Could not be removed - retrying..." -ForegroundColor Red
            }
        }
        else
        {
            $pipelineCount -= 1
        }
    }
}

# Check for datasets that should be removed
WriteHeader "Validating excess datasets in ADF"

foreach ( $dataset in $datasets )
{
    $datasetName = $dataset.Name + ".json"

    # Check if any currently deployed datasets should be removed
    if ( ($branchDatasets | Where-Object { $_.Name -eq $datasetName }).Count -eq 0 )
    {
        Write-Host "$($dataset.Name) doesn't exist in branch, and will be removed..." -ForegroundColor DarkRed -NoNewline
        Remove-AzDataFactoryV2Dataset -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name "$($dataset.Name)" -Force | Out-Null
        Write-host " Removed" -foregroundcolor Green
    }
}

# Check for Linked Services that should be removed
WriteHeader "Validating excess linked services"

foreach ( $linkedService in $linkedServices )
{
    $linkedServiceName = $linkedService.Name + ".json"

    # Check if linked service should be removed
    if ( ($branchLinkedServices | Where-Object { $_.Name -eq $linkedServiceName }).Count -eq 0 )
    {
        Write-Host "$($linkedService.Name) doesn't exist in branch, deleting" -ForegroundColor Red -NoNewline
        Remove-AzDataFactoryV2LinkedService -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name "$($linkedService.Name)" -Force
        Write-host " - Removed" -foregroundcolor Green
    }
}

#Reenable triggers
WriteHeader "Reenable triggers"
$triggers = Get-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName | Where-Object { $disabledPersistentTriggers.Name -notContains "$($_.Name)" }
foreach ( $trigger in $triggers ) {
    Write-Host "Working on trigger: '$($trigger.Name)' ... "
    if ($trigger.Properties.Pipelines) {
        try {
            Start-AzDataFactoryV2Trigger -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $trigger.Name -Force | Out-Null
            Write-Host "`t'$($trigger.Name)' - Enabled"
        } catch {
            if ($trigger.Name -match '^PERSISTENT\s*-') {
                Write-Warning "`tCould not start persistent trigger '$($trigger.Name)'. Persistent triggers are handled manualy from ADF portal, please investigate."
            } else {
                throw
            }
        }
    } else {
        Write-Host "`t'$($trigger.Name)' has no pipeline references defined - Skiped"
    }
}
