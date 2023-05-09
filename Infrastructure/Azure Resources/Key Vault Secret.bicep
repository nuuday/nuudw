param KeyVaultName string
param SecretName string
@secure()
param SecretContentType string
@secure()
param SecretValue string

resource secret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: '${KeyVaultName}/${SecretName}'
  properties:{
    contentType: SecretContentType
    value: SecretValue
  }
}
