variable "project" {
  description = "Name of the project"
}

variable "environment" {
  description = "The Deployment environment"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "iam_role" {
  type        = string
  description = "IAM Role's name"
}

variable "allowed_sgs" {
  type        = list(any)
  description = "Security groups allowed for rules"
}

variable "allowed_subnets" {
  type        = list(any)
  description = "Subnets allowed for EC2 deployment"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
}

variable "target_group_arn" {
  type        = string
  description = "Load Balancer Target Group ARN"
}