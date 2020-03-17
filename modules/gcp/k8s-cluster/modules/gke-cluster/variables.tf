# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "gcp_project" {
	description = "The project ID to host the cluster in"
	type = string
}

variable "location" {
	description = "The location (region or zone) to host the cluster in"
	type = string
}

variable "name" {
	description = "The name of the cluster"
	type = string
}

variable "network" {
	description = "A reference (self link) to the VPC network to host the cluster in"
	type = string
}

variable "subnetwork" {
	description = "A reference (self link) to the subnetwork to host the cluster in"
	type = string
}

variable "service_account_email" {
	description = "The email of the service account associated with each nodes."
	type = string
}

variable "initial_node_count" {
	description = "The initial number of nodes for the pool. In regional or multi-zonal clusters, this is the number of nodes per zone."
	type = number
}

variable "max_node_count" {
	description = "The number of nodes this cluster will get allocated if autoscaling happens."
	type = number
}

variable "machine_type" {
	description = "Type of the machine for each nodes."
	type = string
}

variable "disk_size" {
	description = "Size of the disk space for each node."
	type = number
}

variable "disk_type" {
	description = "Type of the disk for each nodes. It can also be `pd-ssd`, which is more costly."
	type = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------

variable "description" {
	description = "The description of the cluster"
	type = string
	default = ""
}
