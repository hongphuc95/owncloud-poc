module "virtualnetwork" {
  source                  = "./modules/virtualnetwork"
  project                 = var.project
  environment             = var.environment
  resource_group_location = var.resource_group_location
  vnet_address_space      = var.vnet_address_space
  vm_subnets_cidr         = var.vm_subnets_cidr
}

module "vms" {
  source                  = "./modules/vms"
  project                 = var.project
  environment             = var.environment
  resource_group_location = var.resource_group_location
  resource_group_name     = module.virtualnetwork.resource_group_name
  nic_id                  = module.virtualnetwork.nic_id
  vm_size                 = "Standard_A1_v2"
}