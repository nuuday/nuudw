# Set up backend configuration for dev workspace
terraform {
  required_providers {    
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    }

  backend "azurerm" {
    subscription_id    = "83edb3a0-231c-4dbb-ba7e-c657086b78cb"
    resource_group_name   = "nuudw-rg01-prod-terraform"
    storage_account_name = "nuudwst01prodterraform"
    container_name      = "nuudw-tfstate"
    key                  = "rg.tfstate"
  }
}
