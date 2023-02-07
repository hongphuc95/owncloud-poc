terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket = "hongphuc-terraform-backend"
    key    = "owncloudpoc/terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
}