variable "region" {
  type        = string
  description = "AWS Region"
  default     = "eu-west-3"
}

variable "project" {
  type        = string
  description = "Name of the project"
  default     = "owncloud"
}

variable "environment" {
  type        = string
  description = "The Deployment environment"
}

//Networking
variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}