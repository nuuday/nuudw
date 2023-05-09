// General params
param Location string = resourceGroup().location
param Tags object = {}

// Resource specific params
param Name string
param GlobalParams object = {}
param AddGitRepo bool = false
param GitAccountName string = ''
param GitProjectName string = ''
param GitRepositoryName string = ''
param GitCollaborationBranch string = ''
param GitRootFolder string = ''

resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: Name
  location: Location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    globalParameters: GlobalParams
    repoConfiguration: AddGitRepo ? {
      type: 'FactoryVSTSConfiguration'
      accountName: GitAccountName
      projectName: GitProjectName
      repositoryName: GitRepositoryName
      collaborationBranch: GitCollaborationBranch
      rootFolder: GitRootFolder
    } : json('null')
  }
  tags: Tags
}

output DataFactoryManagedIdentity object = adf.identity
output DataFactoryId string = adf.id
output DataFactoryName string = adf.name
