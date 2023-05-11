# Provider configuration for Subscription A
provider "azurerm" {
  features {}
  subscription_id    = "69812263-b31f-4576-8fcd-debbd4bb316e"
}

# Resource Group A
module "resource_group_test" {
  source                = "../../modules/resource-group"
  resource_group_name   = "nuudw-rg01-test"
  resource_group_location = "westeurope"
  resource_group_tags   = {}
}

