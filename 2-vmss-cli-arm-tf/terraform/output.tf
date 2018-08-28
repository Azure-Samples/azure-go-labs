output "vmss_public_ip" {
  value = "${azurerm_public_ip.vmss.fqdn}"
}

output "vmss_admin_password" {
  value = "${random_string.password.result}"
}
