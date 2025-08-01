resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "Devops_project1"
}

# Create virtual network
resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "my_terraform_subnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    
  }
  security_rule {
    name                       = "jenkins"
    priority                   = 1011
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    
  }
  security_rule {
    name                       = "jenkins_out"
    priority                   = 1012
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "8080"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    
  }

  security_rule {
    name                       = "sonar_in"
    priority                   = 1013
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    
  }

  security_rule {
    name                       = "nexus_in"
    priority                   = 1015
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8081"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    
  }
}

# Create network interface
resource "azurerm_network_interface" "my_terraform_nic" {
  name                = "myNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.my_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.my_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
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

# Create virtual machine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name                  = "Jenkins"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  size                  = "Standard_D2as_v4"
  admin_username      = "azureuser"
  admin_password      = "Azure@123456"
  disable_password_authentication = "false"

  # security_type = "TrustedLaunch"
  secure_boot_enabled = "true"
  
  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  #security_type = "TrustedLaunch"
  # source_image_reference {
  #   publisher = "Canonical"
  #   offer     = "ubuntu-24_04-lts"
  #   sku       = "22_04-lts"
  #   version   = "server"
  # }
  source_image_id = "/subscriptions/12d08a43-87ab-49fc-b06f-d1d31622044a/resourcegroups/Devops_project/providers/Microsoft.Compute/galleries/azure_compute_gallery/images/custom_jenkins_image1/versions/1.0.0"
  
  computer_name  = "Jenkins"
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
      user        = "azureuser"
      password = "Azure@123456"
    }

  
  # provisioner "file" {
  #   source      = "jenkins1.sh"
  #   destination = "/tmp/jenkins1.sh"
  # }
  # # provisioner "file" {
  # #   source      = "docker.sh"
  # #   destination = "/tmp/docker.sh"
  # # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "/bin/bash" ,"-c", "/home/azureuser/install.sh"
  #   ]
  # }
}