variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "resource_group_location" {
  description = "The location/region of the resource group."
  type        = string
}

variable "resource_group_tags" {
  description = "Tags to associate with the resource group."
  type        = map(string)
}
