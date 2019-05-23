resource "azurerm_resource_group" "test" {
 name     = "acctestrg"
 location = "West US 2"
}

resource "azurerm_resource_group" "test2" {
 name     = "acctestrg2"
 location = "West US 2"
}

variable "virtual_network" {
 default  = "acctvn"
}

resource "azurerm_virtual_network" "test" {
 name                = "${var.virtual_network}"
 address_space       = ["10.0.0.0/16"]
 location            = "${azurerm_resource_group.test.location}"
 resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_subnet" "test" {
 name                 = "acctsub"
 resource_group_name  = "${azurerm_resource_group.test.name}"
 virtual_network_name = "${azurerm_virtual_network.test.name}"
 address_prefix       = "10.0.2.0/24"
}

resource "azurerm_subnet" "test2" {
 name                 = "acctsub2"
 resource_group_name  = "${azurerm_resource_group.test.name}"
 virtual_network_name = "${azurerm_virtual_network.test.name}"
 address_prefix       = "10.0.5.0/24"
}

resource "azurerm_network_interface" "test" {
 count               = 1
 name                = "acctni${count.index}"
 location            = "${azurerm_resource_group.test.location}"
 resource_group_name = "${azurerm_resource_group.test.name}"

 ip_configuration {
   name                          = "testConfiguration"
   subnet_id                     = "${azurerm_subnet.test.id}"
   private_ip_address_allocation = "dynamic"
 }
}

resource "azurerm_network_interface" "test2" {
 count               = 2
 name                = "acctni2${count.index}"
 location            = "${azurerm_resource_group.test.location}"
 resource_group_name = "${azurerm_resource_group.test.name}"

 ip_configuration {
   name                          = "testConfiguration"
   subnet_id                     = "${azurerm_subnet.test2.id}"
   private_ip_address_allocation = "dynamic"
 }
}

resource "azurerm_managed_disk" "test" {
 count                = 1
 name                 = "datadisk_existing_${count.index}"
 location             = "${azurerm_resource_group.test.location}"
 resource_group_name  = "${azurerm_resource_group.test.name}"
 storage_account_type = "Standard_LRS"
 create_option        = "Empty"
 disk_size_gb         = "1023"
}

resource "azurerm_managed_disk" "test2" {
 count                = 2
 name                 = "datadisk_existing_2_${count.index}"
 location             = "${azurerm_resource_group.test.location}"
 resource_group_name  = "${azurerm_resource_group.test.name}"
 storage_account_type = "Standard_LRS"
 create_option        = "Empty"
 disk_size_gb         = "1023"
}


resource "azurerm_virtual_machine" "test" {
 count                 = 1
 name                  = "acctvm${count.index}"
 location              = "${azurerm_resource_group.test.location}"
 resource_group_name   = "${azurerm_resource_group.test.name}"
 network_interface_ids = ["${element(azurerm_network_interface.test.*.id, count.index)}"]
 vm_size               = "Standard_DS1_v2"

 # Uncomment this line to delete the OS disk automatically when deleting the VM
 # delete_os_disk_on_termination = true

 # Uncomment this line to delete the data disks automatically when deleting the VM
 # delete_data_disks_on_termination = true

 storage_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "16.04-LTS"
   version   = "latest"
 }

storage_os_disk {
   name              = "myosdisk${count.index}"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 # Optional data disks
 storage_data_disk {
   name              = "datadisk_new_${count.index}"
   managed_disk_type = "Standard_LRS"
   create_option     = "Empty"
   lun               = 0
   disk_size_gb      = "1023"
 }

 storage_data_disk {
   name            = "${element(azurerm_managed_disk.test.*.name, count.index)}"
   managed_disk_id = "${element(azurerm_managed_disk.test.*.id, count.index)}"
   create_option   = "Attach"
   lun             = 1
   disk_size_gb    = "${element(azurerm_managed_disk.test.*.disk_size_gb, count.index)}"
 }

 os_profile {
   computer_name  = "hostname"
   admin_username = "testadmin"
   admin_password = "Password1234!"
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 tags {
   environment = "staging"
 }
}

resource "azurerm_virtual_machine" "test2" {
 count                 = 2
 name                  = "acctvm2_${count.index}"
 location              = "${azurerm_resource_group.test2.location}"
 resource_group_name   = "${azurerm_resource_group.test2.name}"
 network_interface_ids = ["${element(azurerm_network_interface.test2.*.id, count.index)}"]
 vm_size               = "Standard_DS1_v2"

 # Uncomment this line to delete the OS disk automatically when deleting the VM
 # delete_os_disk_on_termination = true

 # Uncomment this line to delete the data disks automatically when deleting the VM
 # delete_data_disks_on_termination = true

 storage_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "16.04-LTS"
   version   = "latest"
 }

 storage_os_disk {
   name              = "myosdisk2_${count.index}"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 # Optional data disks
 storage_data_disk {
   name              = "datadisk_new2_${count.index}"
   managed_disk_type = "Standard_LRS"
   create_option     = "Empty"
   lun               = 0
   disk_size_gb      = "1023"
 }

 storage_data_disk {
   name            = "${element(azurerm_managed_disk.test2.*.name, count.index)}"
   managed_disk_id = "${element(azurerm_managed_disk.test2.*.id, count.index)}"
   create_option   = "Attach"
   lun             = 1
   disk_size_gb    = "${element(azurerm_managed_disk.test2.*.disk_size_gb, count.index)}"
 }

 os_profile {
   computer_name  = "hostname"
   admin_username = "testadmin"
   admin_password = "Password1234!"
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 tags {
   environment = "staging"
 }
}