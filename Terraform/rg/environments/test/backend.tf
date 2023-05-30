# Set up backend configuration for dev workspace
terraform {
  required_providers {    
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    }

  backend "azurerm" {
    subscription_id    = "69812263-b31f-4576-8fcd-debbd4bb316e"
    resource_group_name   = "nuudw-rg01-test-terraform"
    storage_account_name = "nuudwst01testterraform"
    container_name      = "nuudw-tfstate"
    key                  = "rg.tfstate"
  }
}
