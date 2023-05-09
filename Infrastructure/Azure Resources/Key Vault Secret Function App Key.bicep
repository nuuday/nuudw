param KeyVaultName string
param SecretName string
@secure()
param SecretContentType string
param FunctionAppId string

resource secret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: '${KeyVaultName}/${SecretName}'
  properties:{
    contentType: SecretContentType
    value: listkeys('${FunctionAppId}/host/default', '2016-08-01').functionKeys.default
  }
}
