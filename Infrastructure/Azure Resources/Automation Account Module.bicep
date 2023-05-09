// General params
param Location string = resourceGroup().location
param Tags object = {}

// Resource specific params
param ModuleName string
param AutomationAccountName string
param Version string 
#disable-next-line no-hardcoded-env-urls
param Url string = 'https://devopsgallerystorage.blob.core.windows.net/packages/${ModuleName}.${Version}.nupkg'



resource aamodule 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  name: '${AutomationAccountName}/${ModuleName}'
  location: Location
  tags: Tags
  properties: {
    contentLink: {
      uri: Url
    }
  }
}
