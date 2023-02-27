variable "project" {
  type        = string
  description = "Name of the project"
}

variable "environment" {
  type        = string
  description = "The Deployment environment"
}

variable "db_engine" {
  type        = string
  description = "Database Engine"
}

variable "db_engine_version" {
  type        = string
  description = "Database version"
}

variable "db_instance" {
  type        = string
  description = "Database instance type"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_username" {
  type        = string
  description = "Database root username"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database root user password"
}

variable "allocated_storage" {
  type        = number
  description = "Allocated storage for the database"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "allowed_sgs" {
  type        = list(any)
  description = "Security groups allowed for rules"
}

variable "allowed_subnets" {
  type        = list(any)
  description = "Subnets allowed for EC2 deployment"
}