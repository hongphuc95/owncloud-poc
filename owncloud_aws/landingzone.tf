locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

module "vpc" {
  source               = "./modules/vpc"
  region               = var.region
  project              = var.project
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = local.production_availability_zones
}

module "lb" {
  source      = "./modules/lb"
  environment = var.environment
  project     = var.project
  vpc_id      = module.vpc.vpc_id
  subnets_id  = module.vpc.public_subnets_id
}

module "ec2" {
  source          = "./modules/compute"
  environment     = var.environment
  project         = var.project
  vpc_id          = module.vpc.vpc_id
  allowed_sgs     = ["${module.lb.alb_sg_id}"]
  allowed_subnets = module.vpc.private_subnets_id
  target_group_arn = module.lb.target_group_arn
  instance_type   = "t2.micro"
  iam_role        = "SSM-TestInstance"
}