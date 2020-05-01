variable "gcp_project" {
  type        = string
  description = "Name of your gcp project"
  validation {
    condition     = can(regex("^[a-z]+-[a-z]+-[a-z]{3,8}$", var.gcp_project))
    error_message = "Must be of this format: org-project-env. e.g. org-project-env."
  }
}

# Optionals

variable "db_name" {
  description = "Name of your database. Needs to follow MySQL identifier rules: https://dev.mysql.com/doc/refman/5.7/en/identifiers.html. If not given, auto generated name will be used."
  type        = string
  default     = null
}

variable "enable_failover_replica" {
  description = "Set to true to enable failover replica."
  type        = bool
  default     = false
}

variable "num_read_replicas" {
  description = "The number of read replicas to create. Cloud SQL will replicate all data from the master to these replicas, which you can use to horizontally scale read traffic."
  type        = number
  default     = 0
}

variable "random_suffix" {
  type        = bool
  description = "Whether to add a random suffix in resource names or not. Default is false."
  default     = false
}

variable "region" {
  type        = string
  description = "Region for the cloud sql instance. If not given, default will be used."
  default     = "asia-southeast1"
}

variable "mysql_version" {
  type        = string
  description = "The engine version of the database, e.g. `MYSQL_5_6` or `MYSQL_5_7`. See https://cloud.google.com/sql/docs/features for supported versions."
  default     = "MYSQL_5_7"
}

variable "machine_type" {
  type        = string
  description = "The machine type for the instances. See this page for supported tiers and pricing: https://cloud.google.com/sql/pricing"
  default     = "db-n1-standard-1"
}

variable "private_network" {
  type        = string
  description = "The resource link for the VPC network from which the Cloud SQL instance is accessible for private IP."
}

