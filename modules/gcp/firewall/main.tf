# ------------------------------------
# A firewall to define for a vpc network.
# ------------------------------------
terraform {
	required_version = "~> 0.12.7"
	experiments = [
		variable_validation
	]
}

resource "random_id" "suffix" {
	byte_length = 2
}

locals {
	project_name_parts = split("-", var.gcp_project)
	suffix = var.random_suffix ? format("-%s", random_id.suffix.hex) : ""
	# ---------------------------------------------------------------------
	# In project name format `<org>-<project>-<env>`, project_name_parts[2]
	# and project_name_parts[1] contains env and project name respectively
	# ---------------------------------------------------------------------
	public_firewall_name = format("%s-%s-%s%s", local.project_name_parts[2], local.project_name_parts[1], "public-allow-ingress-firewall", local.suffix)
	private_firewall_name = format("%s-%s-%s%s", local.project_name_parts[2], local.project_name_parts[1], "private-allow-network-inbound-firewall", local.suffix)
	private_persistence_firewall_name = format("%s-%s-%s%s", local.project_name_parts[2], local.project_name_parts[1], "allow-restricted-inbound-firewall", local.suffix)

	# Define tags as locals so they can be interpolated off of + exported.
	public = "public"
	private = "private"
	private_persistence = "private-persistence"
}

data "google_compute_subnetwork" "public_subnetwork" {
	self_link = var.public_subnetwork
}

data "google_compute_subnetwork" "private_subnetwork" {
	self_link = var.public_subnetwork
}

# ---------------------------------------------------------------------------------------------------------------------
# public - allow ingress from anywhere
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_firewall" "public_allow_all_inbound" {
	name = local.public_firewall_name
	project = var.gcp_project
	network = var.network
	target_tags = [local.public]
	direction = "INGRESS"
	source_ranges = ["0.0.0.0/0"]
	priority = "1000"

	allow {
		protocol = "tcp"
		ports = [
			"443",
			"80"
		]
	}
}

# ---------------------------------------------------------------------------------------------------------------------
# private - allow ingress from within this network
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_firewall" "private_allow_all_network_inbound" {
	name = local.private_firewall_name
	project = var.gcp_project
	network = var.network
	target_tags = [local.private]
	direction = "INGRESS"
	priority = "1000"

	source_ranges = [
		data.google_compute_subnetwork.public_subnetwork.ip_cidr_range,
		data.google_compute_subnetwork.public_subnetwork.secondary_ip_range.0.ip_cidr_range,
		data.google_compute_subnetwork.private_subnetwork.ip_cidr_range,
		data.google_compute_subnetwork.private_subnetwork.secondary_ip_range.0.ip_cidr_range,
	]

	allow {
		protocol = "all"
	}
}

# ---------------------------------------------------------------------------------------------------------------------
# private-persistence - allow ingress from `private` and `private-persistence` instances in this network
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_firewall" "private_allow_restricted_network_inbound" {
	name = local.private_persistence_firewall_name
	project = var.gcp_project
	network = var.network
	target_tags = [local.private_persistence]
	direction = "INGRESS"

	# source_tags is implicitly within this network; tags are only applied to instances that rest within the same network
	source_tags = [
		local.private,
		local.private_persistence
	]

	priority = "1000"

	allow {
		protocol = "all"
	}
}
