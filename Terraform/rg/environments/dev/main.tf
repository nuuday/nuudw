# Provider configuration for Subscription A
provider "azurerm" {
  features {}
  subscription_id = "155e9e90-807a-43a9-811b-8f7bdb95a801"
  
}

# Resource Group A
module "resource_group_dev" {
  source                = "../../modules/resource-group"
  resource_group_name   = "nuudw-rg01-dev"
  resource_group_location = "westeurope"
  resource_group_tags   = {}
}