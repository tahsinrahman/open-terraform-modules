# ---------------------------------------------------------------------------------------------------------------------
# Create the Network & corresponding Router to attach other resources to
# Networks that preserve the default route are automatically enabled for Private Google Access to GCP services
# provided subnetworks each opt-in; in general, Private Google Access should be the default.
# ---------------------------------------------------------------------------------------------------------------------
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
  suffix             = var.random_suffix ? format("-%s", random_id.suffix.hex) : ""
  # ---------------------------------------------------------------------
  # In project name format `<org>-<project>-<env>`, project_name_parts[2]
  # and project_name_parts[1] contains env and project name respectively
  # ---------------------------------------------------------------------
  vpc_name    = format("%s-%s-%s%s", local.project_name_parts[2], local.project_name_parts[1], "vpc", local.suffix)
  subnet_name = format("%s-%s-%s%s", local.project_name_parts[2], local.project_name_parts[1], "subnet", local.suffix)
}

resource "google_compute_network" "vpc" {
  name    = local.vpc_name
  project = var.gcp_project

  # Always define custom subnetworks- one subnetwork per region isn't useful for an opinionated setup
  auto_create_subnetworks = "false"

  # A global routing mode can have an unexpected impact on load balancers; always use a regional mode
  routing_mode = "REGIONAL"
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name = local.subnet_name

  project = var.gcp_project
  region  = var.region
  network = google_compute_network.vpc.self_link

  # Whether the VMs in this subnet can access Google services without assigned external IP addresses.
  private_ip_google_access = true
  # The IP address range of the VPC in CIDR notation. A prefix of /16 is recommended.
  ip_cidr_range = "10.0.0.0/16"

  secondary_ip_range {
    range_name = "private-services"
    # The IP address range of the VPC's secondary address range in CIDR notation. A prefix of /16 is recommended.
    ip_cidr_range = "10.1.0.0/16"
  }

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
