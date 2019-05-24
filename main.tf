data "azurerm_virtual_machine" "test" {
  name                = "inframachine"
  resource_group_name = "InfraProjet"
}

output "virtual_machine_id" {
  value = "${data.azurerm_virtual_machine.test.id}"
}
