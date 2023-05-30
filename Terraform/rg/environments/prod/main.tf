# Provider configuration for Subscription A
provider "azurerm" {
  features {}
  subscription_id = "83edb3a0-231c-4dbb-ba7e-c657086b78cb"
}
# Resource Group A
module "resource_group_prod" {
  source                = "../../modules/resource-group"
  resource_group_name   = "nuudw-rg01-prod"
  resource_group_location = "westeurope"
  resource_group_tags   = {}
}

