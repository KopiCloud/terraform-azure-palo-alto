# Accept the offer terms from Marketplace
resource "azurerm_marketplace_agreement" "palo-alto" {
  publisher = "paloaltonetworks"
  offer     = "vmseries-flex"
  plan      = "hourly"
}

##########################
## Palo Alto FW Node 01 ##
##########################

# Create a public IP for the Palo Alto Firewall #01
resource "azurerm_public_ip" "palo-alto-pip-01" {
  name                = "${local.app_name}-fw01-pip"
  resource_group_name = azurerm_resource_group.conn-rg-01.name
  location            = azurerm_resource_group.conn-rg-01.location
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = {
    name        = "${local.app_name}-fw-pip01"
    environment = var.environment
  }
}

# Create a Public NIC for the Palo Alto Firewall #01
resource "azurerm_network_interface" "palo-alto-nic-public-01" {
  name                = "${local.app_name}-fw01-nic01"
  resource_group_name = azurerm_resource_group.conn-rg-01.name
  location            = azurerm_resource_group.conn-rg-01.location
  
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "${local.app_name}-fw01-nic01-config"
    subnet_id                     = azurerm_subnet.conn-public-subnet-01.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.palo_alto_public_subnet_ip_fw01
    public_ip_address_id          = azurerm_public_ip.palo-alto-pip-01.id
  }
}

# Create a Private NIC for the Palo Alto Firewall #01
resource "azurerm_network_interface" "palo-alto-nic-private-01" {
  name                = "${local.app_name}-fw01-nic02"
  resource_group_name = azurerm_resource_group.conn-rg-01.name
  location            = azurerm_resource_group.conn-rg-01.location
  
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "${local.app_name}-fw01-nic02-config"
    subnet_id                     = azurerm_subnet.conn-private-subnet-01.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.palo_alto_private_subnet_ip_fw01
  }
}

# Create a Management NIC for the Palo Alto Firewall #01
resource "azurerm_network_interface" "palo-alto-nic-mgmt-01" {
  name                = "${local.app_name}-fw01-nic03"
  resource_group_name = azurerm_resource_group.conn-rg-01.name
  location            = azurerm_resource_group.conn-rg-01.location
  
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "${local.app_name}-fw01-nic03-config"
    subnet_id                     = azurerm_subnet.conn-mgmt-subnet-01.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.palo_alto_mgmt_subnet_ip_fw01
  }
}

# Create a HA NIC for the Palo Alto Firewall #01
resource "azurerm_network_interface" "palo-alto-nic-ha-01" {
  name                = "${local.app_name}-fw01-nic04"
  resource_group_name = azurerm_resource_group.conn-rg-01.name
  location            = azurerm_resource_group.conn-rg-01.location
  
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "${local.app_name}-fw01-nic04-config"
    subnet_id                     = azurerm_subnet.conn-fwha-subnet-01.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.palo_alto_ha_subnet_ip_fw01
  }
}

# Create the Palo Alto Firewall VM #01
resource "azurerm_linux_virtual_machine" "palo-alto-fw-vm01" {
  depends_on = [
    azurerm_marketplace_agreement.palo-alto
  ]

  name                = "${local.app_name}-fw01-vm"
  resource_group_name = azurerm_resource_group.conn-rg-01.name
  location            = azurerm_resource_group.conn-rg-01.location
  size                = "Standard_D3_v2"

  admin_username = var.firewall_admin_user
  admin_password = var.firewall_admin_password
  disable_password_authentication = false
  
  network_interface_ids = [
    azurerm_network_interface.palo-alto-nic-mgmt-01.id,
    azurerm_network_interface.palo-alto-nic-public-01.id,
    azurerm_network_interface.palo-alto-nic-private-01.id,
    azurerm_network_interface.palo-alto-nic-ha-01.id
  ]

  os_disk {
    name                 = "${local.app_name}-fw01-disk01"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name      = "byol"
    publisher = "paloaltonetworks"
    product   = "vmseries-flex"
  }

  source_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries-flex"
    sku       = "byol"
    version   = "latest"
  }

  tags = {
    Name        = "${local.app_name}-fw02-vm"
    description = "Palo Alto Firewall #2"
    Environment = var.environment
  }
}

##########################
## Palo Alto FW Node 02 ##
##########################

# Create a public IP for the Palo Alto Firewall 02
resource "azurerm_public_ip" "palo-alto-pip-02" {
  name                = "${local.app_name}-fw02-pip"
  resource_group_name = azurerm_resource_group.conn-rg-01.name
  location            = azurerm_resource_group.conn-rg-01.location
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = {
    name        = "${local.app_name}-fw-pip02"
    environment = var.environment
  }
}

# Create a Public NIC for the Palo Alto Firewall #02
resource "azurerm_network_interface" "palo-alto-nic-public-02" {
  name                = "${local.app_name}-fw02-nic01"
  resource_group_name = azurerm_resource_group.conn-rg-01.name
  location            = azurerm_resource_group.conn-rg-01.location
  
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "${local.app_name}-fw02-nic01-config"
    subnet_id                     = azurerm_subnet.conn-public-subnet-01.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.palo_alto_public_subnet_ip_fw02
    public_ip_address_id          = azurerm_public_ip.palo-alto-pip-02.id
  }
}

# Create a Private NIC for the Palo Alto Firewall #02
resource "azurerm_network_interface" "palo-alto-nic-private-02" {
  name                = "${local.app_name}-fw02-nic02"
  resource_group_name = azurerm_resource_group.conn-rg-01.name
  location            = azurerm_resource_group.conn-rg-01.location
  
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "${local.app_name}-fw02-nic02-config"
    subnet_id                     = azurerm_subnet.conn-private-subnet-01.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.palo_alto_private_subnet_ip_fw02
  }
}

# Create a Management NIC for the Palo Alto Firewall #02
resource "azurerm_network_interface" "palo-alto-nic-mgmt-02" {
  name                = "${local.app_name}-fw02-nic03"
  resource_group_name = azurerm_resource_group.conn-rg-01.name
  location            = azurerm_resource_group.conn-rg-01.location
  
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "${local.app_name}-fw02-nic03-config"
    subnet_id                     = azurerm_subnet.conn-mgmt-subnet-01.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.palo_alto_mgmt_subnet_ip_fw02
  }
}

# Create a HA NIC for the Palo Alto Firewall #02
resource "azurerm_network_interface" "palo-alto-nic-ha-02" {
  name                = "${local.app_name}-fw02-nic04"
  resource_group_name = azurerm_resource_group.conn-rg-01.name
  location            = azurerm_resource_group.conn-rg-01.location
  
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "${local.app_name}-fw02-nic04-config"
    subnet_id                     = azurerm_subnet.conn-fwha-subnet-01.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.palo_alto_ha_subnet_ip_fw02
  }
}

# Create the Palo Alto Firewall VM #02
resource "azurerm_linux_virtual_machine" "palo-alto-fw02-vm" {
  depends_on = [
    azurerm_marketplace_agreement.palo-alto
  ]

  name                = "${local.app_name}-fw02-vm"
  resource_group_name = azurerm_resource_group.conn-rg-01.name
  location            = azurerm_resource_group.conn-rg-01.location
  size                = "Standard_D3_v2"

  admin_username = var.firewall_admin_user
  admin_password = var.firewall_admin_password
  disable_password_authentication = false
  
  network_interface_ids = [
    azurerm_network_interface.palo-alto-nic-mgmt-02.id,
    azurerm_network_interface.palo-alto-nic-public-02.id,
    azurerm_network_interface.palo-alto-nic-private-02.id,
    azurerm_network_interface.palo-alto-nic-ha-02.id
  ]

  os_disk {
    name                 = "${local.app_name}-fw02-disk01"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name      = "byol"
    publisher = "paloaltonetworks"
    product   = "vmseries-flex"
  }

  source_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries-flex"
    sku       = "byol"
    version   = "latest"
  }

  tags = {
    Name        = "${local.app_name}-fw02-vm"
    description = "Palo Alto Firewall #2"
    Environment = var.environment
  }
}
