resource "azurerm_resource_group" "rg" {
  name     = "${var.project}-${var.environment}-rg"
  location = var.resource_group_location
  tags = {
    Name        = "${var.project}-${var.environment}-rg"
    Environment = "${var.environment}"
  }
}