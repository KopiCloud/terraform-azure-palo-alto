#############################
## Palo Alto Load Balancer ##
#############################

# Create a Private Load Balancer
resource "azurerm_lb" "palo_alto_lb" {
  depends_on = [
    azurerm_linux_virtual_machine.palo-alto-fw-vm01,
    azurerm_linux_virtual_machine.palo-alto-fw-vm02,
  ]

  name                = "${local.app_name}-fw-lb"
  resource_group_name = azurerm_resource_group.conn-rg-01.name
  location            = azurerm_resource_group.conn-rg-01.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name               = "${local.app_name}-fw-lb-ip-address"
    subnet_id          = azurerm_subnet.conn-private-subnet-01.id
    private_ip_address = var.palo_alto_private_subnet_lb_ip
    
    private_ip_address_allocation = "Static"
  }

  tags = {
    description = "Palo Alto Internal Load Balancer"
    Environment = var.environment
  }
}

# Create a Load Balancer Backend Address Pool
resource "azurerm_lb_backend_address_pool" "palo_alto_lb" {
  depends_on = [azurerm_lb.palo_alto_lb]

  loadbalancer_id = azurerm_lb.palo_alto_lb.id
  name            = "${local.app_name}-fw-lb-address-pool"
}

# Create Load Balancer Health Probe
resource "azurerm_lb_probe" "palo_alto_lb_probe" {
  depends_on = [azurerm_lb.palo_alto_lb]

  loadbalancer_id = azurerm_lb.palo_alto_lb.id
  name            = "${local.app_name}-fw-lb-probe"
  protocol        = "Tcp"
  port            = 22

  interval_in_seconds = 5
}

# Create Load Balancer Rule for HA
# Enable HA = protocol = "All" AND frontend_port = 0 AND backend_port = 0 
resource "azurerm_lb_rule" "palo_alto_lb_rule_ha" {
  depends_on = [azurerm_lb.palo_alto_lb]

  name                           = "${local.app_name}-fw-lb-probe-ha-rule"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = azurerm_lb.palo_alto_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.palo_alto_lb.id]
  probe_id                       = azurerm_lb_probe.palo_alto_lb_probe.id
  loadbalancer_id                = azurerm_lb.palo_alto_lb.id
}

# Add Palo Alto Firewall VM 01 to Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "palo_alto_fw_01" {
  depends_on = [
    azurerm_lb.palo_alto_lb,
    azurerm_linux_virtual_machine.palo-alto-fw-vm01
  ]

  network_interface_id    = azurerm_network_interface.palo-alto-nic-private-01.id
  ip_configuration_name   = "${local.app_name}-fw01-nic02-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.palo_alto_lb.id
}

# Add Palo Alto Firewall VM 02 to Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "palo_alto_fw_02" {
  depends_on = [
    azurerm_lb.palo_alto_lb,
    azurerm_linux_virtual_machine.palo-alto-fw-vm02
  ]

  network_interface_id    = azurerm_network_interface.palo-alto-nic-private-02.id
  ip_configuration_name   = "${local.app_name}-fw02-nic02-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.palo_alto_lb.id
}
