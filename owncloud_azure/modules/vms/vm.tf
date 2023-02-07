resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.project}-${var.environment}-vm"
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [var.nic_id]
  vm_size               = var.vm_size

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.project}-${var.environment}-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "owncloud"
    admin_username = "owncloud"
    admin_password = "Ninetofive95"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    Name        = "${var.project}-${var.environment}-vm"
    Environment = "${var.environment}"
  }
}