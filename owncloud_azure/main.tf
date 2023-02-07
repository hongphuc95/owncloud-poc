terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }

  #   backend "s3" {
  #     bucket = "hongphuc-terraform-backend"
  #     key    = "owncloudpoc/terraform.tfstate"
  #   }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}