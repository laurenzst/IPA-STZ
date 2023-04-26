#   ⡇⠄⣿⣿⣿⣿⡇⠄⣿⣿⠄⠙⢿⣿⣿⠟⠉⠄⣿⣿⠄⢀⣀⣀⣀⡀⠙⣿
#   ⡇⠄⣿⣿⣿⣿⡇⠄⣿⣿⠄⢠⡀⠙⠋⢀⡄⠄⣿⣿⠄⠈⠉⠉⠉⠁⠄⣿
#   ⣧⠄⠙⠻⠿⠛⠁⣠⣿⣿⠄⢸⣿⣦⣴⣿⡇⠄⣿⣿⠄⠘⠛⠛⠛⠛⠄⣼
#   ⣿⣿⣶⣶⣶⣶⣾⣿⣿⣿⣶⣾⣿⣿⣿⣿⣷⣶⣿⣿⣶⣶⣶⣶⣶⣶⣾⣿
#   ⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄


#   Date:          2023.04.17
#   Creator:       Laurenz Ströbele, laurenz.stroebele@umb.ch | Team Linux Operations UMB AG
#   Filename:      k8s-workernode.tf
#   Description:   Resource Creation for Azure Kubernetes Worker Node Virtual Machine(s)
#   Contains:
#     - Public IPs for Worker(s)
#     - Network Interface for Worker(s)
#     - Network Security Group to Network Interface Connection for Worker(s)
#     - SSH key creation for Worker(s)
#     - local key creation
#     - Virtual Machine Worker Node(s)

##############################################################################################

# Create public IPs 
resource "azurerm_public_ip" "pip_worker" {
  count               = var.WorkerCount
  name                = "${var.vmnameWorker}${count.index}-pip0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  tags = {
        environment = "K8s Public IP Worker"
    }
}

# Create Network Interface
resource "azurerm_network_interface" "nic_worker" {
  count               = var.WorkerCount
  name                = "${var.vmnameWorker}${count.index}-nic0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.pip_worker.*.id, count.index)}"
  }
  tags = {
        environment = "K8s NIC Worker"
    }
}

# Connect the Security Group to the Network Interface
resource "azurerm_network_interface_security_group_association" "sga_worker" {
    count                     = var.WorkerCount
    network_interface_id      = "${element(azurerm_network_interface.nic_worker.*.id, count.index)}"
    network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create (and display) an SSH key
resource "tls_private_key" "k8s_ssh_worker" {
    algorithm = "RSA"
    rsa_bits = 4096
    depends_on = [
        azurerm_network_interface_security_group_association.sga_worker
    ]
}

# Create local key
resource "local_file" "worker_keyfile" {
    content         = tls_private_key.k8s_ssh_worker.private_key_pem
    filename        = "worker_key.pem"
    file_permission = "0400"
}

# Create Virtual Machine for Worker node
resource "azurerm_linux_virtual_machine" "azvmworker" {
    count                 = var.WorkerCount
    name                  = "${var.vmnameWorker}${count.index}"
    location              = azurerm_resource_group.rg.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids  = ["${element(azurerm_network_interface.nic_worker.*.id, count.index)}"]
    size                  = var.vmType
    os_disk {
        name              = "${var.vmnameWorker}${count.index}-disk0"
        caching           = "ReadWrite"
        storage_account_type = var.diskType
    }
    source_image_reference {
       publisher = "Canonical"
       offer     = "0001-com-ubuntu-server-jammy"
       sku       = "22_04-lts-gen2"
       version   = "latest"
    }
    computer_name  = "${var.vmnameWorker}${count.index}"
    admin_username = "ansible"
    disable_password_authentication = true
    admin_ssh_key {
        username       = "ansible"
        public_key     = tls_private_key.k8s_ssh_worker.public_key_openssh
    }
    tags = {
        environment = "Worker_Node"
    }
    depends_on = [
        tls_private_key.k8s_ssh_worker
    ]
}