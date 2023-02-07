resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project}-${var.environment}-vnet"
  address_space       = var.vnet_address_space
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    Name        = "${var.project}-${var.environment}-vnet"
    Environment = "${var.environment}"
  }
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "${var.project}-${var.environment}-vm-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.vm_subnets_cidr
}

resource "azurerm_network_security_group" "vm_subnet_nsg" {
  name                = "${var.project}-${var.environment}-vm-nsg"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    Name        = "${var.project}-${var.environment}-vm-nsg"
    Environment = "${var.environment}"
  }
}

resource "azurerm_subnet_network_security_group_association" "vm_subnet_nsg_associate" {
  depends_on                = [azurerm_network_security_rule.vm_nsg_rule_inbound]
  subnet_id                 = azurerm_subnet.vm_subnet.id
  network_security_group_id = azurerm_network_security_group.vm_subnet_nsg.id
}

locals {
  web_inbound_ports_map = {
    "100" : "80",
    "110" : "443",
    "120" : "22"
  }
}

resource "azurerm_network_security_rule" "vm_nsg_rule_inbound" {
  for_each                    = local.web_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.vm_subnet_nsg.name
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.project}-${var.environment}-nic"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "vmconfiguration"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}