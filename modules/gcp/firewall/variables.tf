# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------
variable "gcp_project" {
	type = string
	description = "Name of your gcp project"
	validation {
		condition = can(regex("^[a-z]+-[a-z]+-[a-z]{3,8}$", var.gcp_project))
		error_message = "Must be of this format: org-project-env. e.g. airasia-payments-dev."
	}
}

variable "network" {
	description = "A reference (self_link) to the VPC network to apply firewall rules to"
}

variable "public_subnetwork" {
	description = "A reference (self_link) to the public subnetwork of the network"
}

variable "private_subnetwork" {
	description = "A reference (self_link) to the private subnetwork of the network"
}

# ------------------------------------------
# Optionals
# ------------------------------------------
variable "random_suffix" {
	type = bool
	description = "Whether to add a random suffix in resource names or not. Default is false."
	default = false
}