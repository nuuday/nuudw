# Created by Dinesh Padala 
# Last change : 2023-05-10 (YYYY-MM-DD)
# This file consists of the resource group tf code 
# application_service: nuudw
# spoc_tags: MILAN@nuuday.dk
# modules/resource_group/main.tf
locals {
  common_tags = {
    application_service  = "nuudw"
    spoc_tags      = "MILAN@nuuday.dk"  
  }
}
# Resource Group
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.resource_group_location
   tags = "${merge( local.common_tags, var.resource_group_tags)}"
}

