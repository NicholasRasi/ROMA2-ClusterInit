# Create the public IPs
resource "azurerm_public_ip" "gpuw" {
  count               = var.gpuw_count
  name                = "GPUW-IP-${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

# Create the network interfaces
resource "azurerm_network_interface" "gpuw" {
  count               = var.gpuw_count
  name                = "GPUW-NIC-${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "gpuw-ipconfig-${count.index + 1}"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.gpuw[count.index].id
  }
}

# Create network security group
resource "azurerm_network_security_group" "gpuw" {
  name                = "gpuWorkerSecurityGroup"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Create security rule
resource "azurerm_network_security_rule" "gpuw" {
  name                        = "GPUW-security-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["22", "10250", "30000-32767"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.gpuw.name
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "gpuw" {
  count                     = var.gpuw_count
  network_interface_id      = azurerm_network_interface.gpuw[count.index].id
  network_security_group_id = azurerm_network_security_group.gpuw.id
}

# Create the VM
resource "azurerm_linux_virtual_machine" "gpuw" {
  count          = var.gpuw_count
  admin_username = "azureuser"
  location       = azurerm_resource_group.main.location
  name           = "GPUW-${count.index + 1}"
  network_interface_ids = [
    azurerm_network_interface.gpuw.*.id[count.index],
  ]

  resource_group_name = azurerm_resource_group.main.name
  size                = var.gpuw_size

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    role = "gpuw"
  }
}

# Apply extension
resource "azurerm_virtual_machine_extension" "gpuw" {
  count                = var.gpuw_count
  name                 = "NvidiaGpuDriverLinux"
  virtual_machine_id   = azurerm_linux_virtual_machine.gpuw[count.index].id
  publisher            = "Microsoft.HpcCompute"
  type                 = "NvidiaGpuDriverLinux"
  type_handler_version = "1.3"
}