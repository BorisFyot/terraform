#Resource Group
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "InfraProjet"
    location = "westeurope"

    tags {
        environment = "Terraform Demo"
    }
}


#Jenkins public IP
resource "azurerm_public_ip" "PIP" {
    count                        = 3
    name                         = "${element(var.PIP_Name, count.index)}"
    location                     = "${azurerm_resource_group.myterraformgroup.location}"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    allocation_method            = "Dynamic"

    tags {
        environment = "Terraform Demo"
    }
}


#Jenkins Network Interface
resource "azurerm_network_interface" "NIC" {
    count               = 3
    name                = "${element(var.NIC_Name, count.index)}"
    location            = "${azurerm_resource_group.myterraformgroup.location}"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"
    network_security_group_id = "${data.azurerm_network_interface.test.network_security_group_id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${data.azurerm_subnet.test.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.PIP.*.id, count.index)}"
    }

    tags {
        environment = "Terraform Demo"
    }
}



#Jenkins VM
resource "azurerm_virtual_machine" "JenkinsVM" {
    count                 = 3
    name                  = "${element(var.VM_Name, count.index)}"
    location              = "${azurerm_resource_group.myterraformgroup.location}"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${element(azurerm_network_interface.NIC.*.id, count.index)}"]
    vm_size               = "Standard_B1ms"

    storage_os_disk {
        name              = "${element(var.storage_Name, count.index)}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "${element(var.VM_Name, count.index)}"
        admin_username = "azureuser"
    }

    tags {
        environment = "Terraform Demo"
    }
    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC25G/wnpjYHounebrOuLmEjrb3FSpXCTUDATuBXfISLeg4LYUdl6Xdf5gEpnC4tu1vrWJ8Kx8OtJbcErKcaN6fa8x0M8O5C3xyuaAcnjc4wZsJExXZTLE7cuJrdVmtdrn6slA+bYzyecFb35h8S6gO1uyNGNgjbkwdPU/khKzqwHd2gbxg56NNQFMFGwlLV2Lp9BubGD+ksMwUS9G81c0F6qEgdJ3bPfOql03qEwA+HeMdBWlXaA2lPpiV9i6MgbVNGLA6qeUL1sMp3jA5FdRq9SOxVO9fncz9Pbm04k8li0AtN7w/4lYtC0SzL8Y+5zirc32+ovCe9eFWde7Vz0M5 adminl@localhost.localdomain"
        }
    }

}
