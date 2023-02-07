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

variable "subnets_id" {
  type        = list(any)
  description = "LB subnets ID"
}

variable "allowed_cidr_blocks" {
  type        = list(any)
  description = "The ipv4 CIDR block allowed for rules"
  default     = ["0.0.0.0/0"]
}

variable "allowed_ipv6_cidr_blocks" {
  type        = list(any)
  description = "The ipv6 CIDR block allowed for rules"
  default     = ["::/0"]
}
