output "master_instance_name" {
  description = "The name of the master database instance"
  value       = module.mysql.master_instance_name
}

output "master_db_name" {
  description = "The name of the master database."
  value       = module.mysql.db_name
}

output "master_private_ip_address" {
  description = "The public IPv4 address of the master instance."
  value       = module.mysql.master_private_ip_address
}

output "master_instance" {
  description = "Self link to the master instance"
  value       = module.mysql.master_instance
}

output "app_user_name" {
  description = "The user to be used by applications."
  value       = module.mysql.app_user_name
}

output "app_user_password" {
  description = "Password for the user to be used by applications."
  value       = module.mysql.app_user_password
}
