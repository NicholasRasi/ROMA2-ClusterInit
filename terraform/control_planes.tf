# Create the public IPs
resource "azurerm_public_ip" "cp" {
  count               = var.cp_count
  name                = "CP-IP-${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

# Create the network interfaces
resource "azurerm_network_interface" "cp" {
  count               = var.cp_count
  name                = "CP-NIC-${count.index + 1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "cp-ipconfig-${count.index + 1}"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.cp[count.index].id
  }
}

# Create network security group
resource "azurerm_network_security_group" "cp" {
  name                = "controlPlaneSecurityGroup"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Create security rule
resource "azurerm_network_security_rule" "cp" {
  name                        = "CP-security-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["22", "6443", "2379-2380", "10250-10252", "5000-5003", "8000", "8080"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.cp.name
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "cp" {
  count                     = var.cp_count
  network_interface_id      = azurerm_network_interface.cp[count.index].id
  network_security_group_id = azurerm_network_security_group.cp.id
}

# Create the VM
resource "azurerm_linux_virtual_machine" "cp" {
  count          = var.cp_count
  admin_username = "azureuser"
  location       = azurerm_resource_group.main.location
  name           = "CP-${count.index + 1}"
  network_interface_ids = [
    azurerm_network_interface.cp.*.id[count.index],
  ]

  resource_group_name = azurerm_resource_group.main.name
  size                = var.cp_size

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
    role = "cp"
  }
}
