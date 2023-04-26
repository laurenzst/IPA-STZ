#   ⡇⠄⣿⣿⣿⣿⡇⠄⣿⣿⠄⠙⢿⣿⣿⠟⠉⠄⣿⣿⠄⢀⣀⣀⣀⡀⠙⣿
#   ⡇⠄⣿⣿⣿⣿⡇⠄⣿⣿⠄⢠⡀⠙⠋⢀⡄⠄⣿⣿⠄⠈⠉⠉⠉⠁⠄⣿
#   ⣧⠄⠙⠻⠿⠛⠁⣠⣿⣿⠄⢸⣿⣦⣴⣿⡇⠄⣿⣿⠄⠘⠛⠛⠛⠛⠄⣼
#   ⣿⣿⣶⣶⣶⣶⣾⣿⣿⣿⣶⣾⣿⣿⣿⣿⣷⣶⣿⣿⣶⣶⣶⣶⣶⣶⣾⣿
#   ⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄


#   Date:          2023.04.17
#   Creator:       Laurenz Ströbele, laurenz.stroebele@umb.ch | Team Linux Operations UMB AG
#   Filename:      ansible.tf
#   Description:   Ansible Configurations and triggering Ansible Automation
#   Contains:
#     - create local inventory file for Ansible hosts
#     - trigger Ansible Process

##############################################################################################

# Update Ansible inventory
resource "local_file" "ansible_host" {
    depends_on = [
      azurerm_linux_virtual_machine.azvmmaster, 
      azurerm_linux_virtual_machine.azvmworker
    ]

    filename    = "inventory"
    content     = <<EOF
[master]
%{ for index, ip in azurerm_linux_virtual_machine.azvmmaster ~}
${azurerm_linux_virtual_machine.azvmmaster[index].name} ansible_host=${azurerm_linux_virtual_machine.azvmmaster[index].public_ip_address} ansible_user=${azurerm_linux_virtual_machine.azvmmaster[index].admin_username} ansible_ssh_private_key_file=./${local_file.master_keyfile.filename} ansible_become=true ansible_ssh_common_args='-o StrictHostKeyChecking=no' 
%{ endfor ~}

[worker]
%{ for index, ip in azurerm_linux_virtual_machine.azvmworker ~}
${azurerm_linux_virtual_machine.azvmworker[index].name} ansible_host=${azurerm_linux_virtual_machine.azvmworker[index].public_ip_address} ansible_user=${azurerm_linux_virtual_machine.azvmworker[index].admin_username} ansible_ssh_private_key_file=./${local_file.worker_keyfile.filename} ansible_become=true ansible_ssh_common_args='-o StrictHostKeyChecking=no' 
%{ endfor ~}
EOF
}

resource "null_resource" "Configuration_Cluster" {
    depends_on = [
      local_file.ansible_host
    ]
  provisioner "local-exec" {
    command = "sleep 10"
    }
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory Ansible-Deployment.yml"
    }
}