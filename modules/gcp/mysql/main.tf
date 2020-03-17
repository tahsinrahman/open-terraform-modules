# -------------------------------------------------------
# A private IP Google Cloud SQL Instance
# -------------------------------------------------------
terraform {
	required_version = "~> 0.12.7"
	experiments = [
		variable_validation]
}

provider "google-beta" {
	project = var.gcp_project
	region = var.region
}

resource "random_string" "suffix" {
	length = 6
	special = false
	upper = false
}

locals {
	project_name_parts = split("-", var.gcp_project)
	suffix = var.random_suffix ? format("-%s", random_string.suffix.result) : ""
	mysql_engine = "MYSQL_5_7"
	db_name = format("%s-%s-%s%s", local.project_name_parts[2], local.project_name_parts[1], "sql-db", local.suffix)
	# ---------------------------------------------------------------------
	# In project name format `<org>-<project>-<env>`, project_name_parts[2]
	# and project_name_parts[1] contains env and project name respectively
	# ---------------------------------------------------------------------
	instance_name = format("%s-%s-%s%s", local.project_name_parts[2], local.project_name_parts[1], "sql-instance", local.suffix)
	private_ip_name = format("%s-%s-%s%s", local.project_name_parts[2], local.project_name_parts[1], "sql-pvt-ip", local.suffix)
}

# ------------------------------------------------------------------------------
# Connect with the VPC
# ------------------------------------------------------------------------------

# Reserve global internal address range for the peering
resource "google_compute_global_address" "private_ip_address" {
	provider = google-beta
	name = local.private_ip_name
	purpose = "VPC_PEERING"
	address_type = "INTERNAL"
	prefix_length = 16
	network = var.private_network
}

# Establish VPC network peering connection using the reserved address range
resource "google_service_networking_connection" "private_vpc_connection" {
	provider = google-beta
	network = var.private_network
	service = "servicenetworking.googleapis.com"
	reserved_peering_ranges = [
		google_compute_global_address.private_ip_address.name
	]
}

# ------------------------------------------------------------------------------
# Create db instance with a private IP
# ------------------------------------------------------------------------------
module "mysql" {
	source = "./modules/cloud-sql"
	project = var.gcp_project
	region = var.region
	name = local.instance_name
	db_name = var.db_name == null ? local.db_name : var.db_name
	enable_failover_replica = var.enable_failover_replica
	num_read_replicas = var.num_read_replicas
	disk_autoresize = true

	engine = local.mysql_engine
	machine_type = var.machine_type
	# Pass the private network link to the module
	private_network = var.private_network
	# Wait for the vpc connection to complete
	dependencies = [
		google_service_networking_connection.private_vpc_connection.network
	]
}

# ------------------------------------------------------------------------------
# Root user managed in google secrets
# ------------------------------------------------------------------------------
resource "google_secret_manager_secret" "root_user_pw" {
	provider = google-beta
	secret_id = format("%s-%s", module.mysql.master_user_name, "password")
	labels = {
		mysql_root_user = module.mysql.master_user_name
	}

	replication {
		user_managed {
			replicas {
				location = var.region
			}
		}
	}

	depends_on = [
		module.mysql
	]
}

resource "google_secret_manager_secret_version" "root_user_pw_version" {
	provider = google-beta
	secret = google_secret_manager_secret.root_user_pw.id
	secret_data = module.mysql.master_user_password

	depends_on = [
		module.mysql
	]
}

