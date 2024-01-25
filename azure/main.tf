provider "azurerm" {
}

resource "azurerm_linux_virtual_machine" "my_linux_vm" {
  location = "eastus"

  size = "Standard_F16s" # <<<<< Try changing this to Standard_F16s_v2 to compare the costs

  tags = {
    Environment = "production"
    Service = "web-app"
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_app_service_plan" "my_app_service" {
  location = "eastus"

  sku {
    tier     = "PremiumV2"
    size     = "P1v2"
    capacity = 4 # <<<<< Try changing this to 8 to compare the costs
  }

  tags = {
    Environment = "Prod"
    Service = "web-app"
  }
}

resource "azurerm_function_app" "my_function" {
  location                   = "eastus"

  tags = {
    Environment = "Prod"
  }
}
