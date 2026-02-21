resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.rg_nm
}

# Create virtual network
resource "azurerm_virtual_network" "my_terraform_network" {
  count = length(var.computer_names)
  name                = "myVnet-${terraform.workspace}-${count.index}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "my_terraform_subnet" {
  count = length(var.computer_names)
  name                 = "mySubnet-${terraform.workspace}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network[count.index].name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "my_terraform_public_ip" {
  count = length(var.computer_names)
  name                = "myPublicIP-${terraform.workspace}-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "my_terraform_nsg" {
  count = length(var.computer_names)
  name                = "myNetworkSecurityGroup-${terraform.workspace}-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  dynamic "security_rule" {
    for_each = var.inbound_ports
    content {
      name = security_rule.key
      priority = 1000 + index(keys(var.inbound_ports), security_rule.key)
      direction = var.direction
      access = var.access
      protocol = var.protocol
      source_port_range = var.source_port_range
      destination_port_range = security_rule.value
      source_address_prefix = var.source_port_range
      destination_address_prefix = var.source_port_range
    }
    
  }

  security_rule {
    name                       = "jenkins_out"
    priority                   = 1012
    direction                  = var.direction
    access                     = var.access
    protocol                   = var.protocol
    source_port_range          = "8080"
    destination_port_range     = var.source_port_range
    source_address_prefix      = var.source_port_range
    destination_address_prefix = var.source_port_range
    
  }

}

# Create network interface
resource "azurerm_network_interface" "my_terraform_nic" {
  count = length(var.computer_names)
  name                = "myNIC-${terraform.workspace}-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "my_nic_configuration-${terraform.workspace}-${count.index}"
    subnet_id                     = azurerm_subnet.my_terraform_subnet[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip[count.index].id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  count = length(var.computer_names)
  network_interface_id      = azurerm_network_interface.my_terraform_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg[count.index].id
}

# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
# resource "azurerm_storage_account" "my_storage_account" {
#   name                     = "diag${random_id.random_id.hex}"
#   location                 = azurerm_resource_group.rg.location
#   resource_group_name      = azurerm_resource_group.rg.name
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_rg
}

data "azurerm_key_vault_secret" "jenkins-admin-password" {
  name         = "jenkins-admin-password"
  key_vault_id = data.azurerm_key_vault.kv.id
}
data "azurerm_key_vault_secret" "jenkins-admin-username" {
  name         = "jenkins-admin-username"
  key_vault_id = data.azurerm_key_vault.kv.id
}
# Create virtual machine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  count                 = length(var.computer_names)
  name                  = var.computer_names[count.index]
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic[count.index].id]
  size                  = var.size
  admin_username      = data.azurerm_key_vault_secret.jenkins-admin-username.value
  admin_password      = data.azurerm_key_vault_secret.jenkins-admin-password.value
  disable_password_authentication = "false"

  #security_type = "TrustedLaunch"
  secure_boot_enabled = "true"
  
  os_disk {
    name                 = "myOsDisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

source_image_reference {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
  version   = "latest"
}
  #source_image_id = var.source_image
provisioner "file" {
  source      = "jenkins1.sh"
  destination = "/tmp/jenkins1.sh"
}
provisioner "remote-exec" {
  inline = [ "chmod +x /tmp/jenkins1.sh" , "/tmp/jenkins1.sh" ]
  
}
  computer_name  = var.computer_names[count.index]
  #custom_data = base64encode(file("jenkins1.sh"))
  #admin_username = var.username

  # admin_ssh_key {
  #   username   = var.username
  #   public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
  # }

  # boot_diagnostics {
  #   storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  # }
 
  
  connection {
      type        = "ssh"
      host        = self.public_ip_address
      user        = data.azurerm_key_vault_secret.jenkins-admin-username.value
      password = data.azurerm_key_vault_secret.jenkins-admin-password.value
    }

  
}