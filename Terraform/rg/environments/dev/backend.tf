# Set up backend configuration for dev workspace
terraform {
  required_providers {    
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    }


  backend "azurerm" {
    subscription_id    = "155e9e90-807a-43a9-811b-8f7bdb95a801"
    resource_group_name   = "nuudw-rg01-dev-terraform"
    storage_account_name = "nuudwst01devterraform"
    container_name      = "nuudw-tfstate"
    key                  = "rg.tfstate"
  }
}
