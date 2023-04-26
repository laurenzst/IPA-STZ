#   ⡇⠄⣿⣿⣿⣿⡇⠄⣿⣿⠄⠙⢿⣿⣿⠟⠉⠄⣿⣿⠄⢀⣀⣀⣀⡀⠙⣿
#   ⡇⠄⣿⣿⣿⣿⡇⠄⣿⣿⠄⢠⡀⠙⠋⢀⡄⠄⣿⣿⠄⠈⠉⠉⠉⠁⠄⣿
#   ⣧⠄⠙⠻⠿⠛⠁⣠⣿⣿⠄⢸⣿⣦⣴⣿⡇⠄⣿⣿⠄⠘⠛⠛⠛⠛⠄⣼
#   ⣿⣿⣶⣶⣶⣶⣾⣿⣿⣿⣶⣾⣿⣿⣿⣿⣷⣶⣿⣿⣶⣶⣶⣶⣶⣶⣾⣿
#   ⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄


#   Date:          2023.04.17
#   Creator:       Laurenz Ströbele, laurenz.stroebele@umb.ch | Team Linux Operations UMB AG
#   Filename:      k8s-masternode.tf
#   Description:   Resource Creation for Azure Kubernetes Master Node Virtual Machine(s)
#   Contains:
#     - Public IPs for Master(s)
#     - Network Interface for Master(s)
#     - Network Security Group to Network Interface Connection for Master(s)
#     - SSH key creation for Masternodes
#     - local key creation
#     - Virtual Machine Master Node(s)

##############################################################################################

# Create public IPs 
resource "azurerm_public_ip" "pip_master" {
  count               = var.MasterCount
  name                = "${var.vmnameMaster}${count.index}-pip0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  tags = {
        environment = "K8s Public IP Master"
    }
}

# Create Network Interface
resource "azurerm_network_interface" "nic_master" {
  count               = var.MasterCount
  name                = "${var.vmnameMaster}${count.index}-nic0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.pip_master.*.id, count.index)}"
  }
  tags = {
        environment = "K8s NIC Master"
    }
}

# Connect the Security Group to the Network Interface
resource "azurerm_network_interface_security_group_association" "sga_master" {
    count                     = var.MasterCount
    network_interface_id      = "${element(azurerm_network_interface.nic_master.*.id, count.index)}"
    network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create (and display) an SSH key
resource "tls_private_key" "k8s_ssh_master" {
    algorithm = "RSA"
    rsa_bits = 4096
    depends_on = [
        azurerm_network_interface_security_group_association.sga_master
    ]
}

# Create local key
resource "local_file" "master_keyfile" {
    content         = tls_private_key.k8s_ssh_master.private_key_pem
    filename        = "master_key.pem"
    file_permission = "0400"
}

# Create Virtual Machine for Master node
resource "azurerm_linux_virtual_machine" "azvmmaster" {
    count                 = var.MasterCount
    name                  = "${var.vmnameMaster}${count.index}"
    location              = azurerm_resource_group.rg.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids  = ["${element(azurerm_network_interface.nic_master.*.id, count.index)}"]
    size                  = var.vmType
    os_disk {
        name              = "${var.vmnameMaster}${count.index}-disk0"
        caching           = "ReadWrite"
        storage_account_type = var.diskType
    }
    source_image_reference {
       publisher = "Canonical"
       offer     = "0001-com-ubuntu-server-jammy"
       sku       = "22_04-lts-gen2"
       version   = "latest"
    }
    computer_name  = "${var.vmnameMaster}${count.index}"
    admin_username = "ansible"
    disable_password_authentication = true
    admin_ssh_key {
        username       = "ansible"
        public_key     = tls_private_key.k8s_ssh_master.public_key_openssh
    }
    tags = {
        environment = "Master_Node"
    }
    depends_on = [
        tls_private_key.k8s_ssh_master
    ]
}