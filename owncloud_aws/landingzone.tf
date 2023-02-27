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
  source           = "./modules/compute"
  environment      = var.environment
  project          = var.project
  vpc_id           = module.vpc.vpc_id
  allowed_sgs      = ["${module.lb.alb_sg_id}"]
  allowed_subnets  = module.vpc.private_subnets_id
  target_group_arn = module.lb.target_group_arn
  instance_type    = "t4g.micro"
  iam_role         = "Owncloud"
}

module "db" {
  source            = "./modules/storage"
  environment       = var.environment
  project           = var.project
  vpc_id            = module.vpc.vpc_id
  db_engine         = "mariadb"
  db_engine_version = "10.6.10"
  db_instance       = "db.t2.micro"
  allowed_sgs       = ["${module.ec2.ec2_sg_id}"]
  allowed_subnets   = module.vpc.private_subnets_id
  allocated_storage = 5
  db_name           = "ownclouddb"
  db_username       = var.project
  db_password       = var.project
}