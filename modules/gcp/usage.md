## GCP Modules

Check the `variables.tf` of each module to know other adjustable options.

### Common Variables

- `gcp_project`: The Google Cloud Project where your infra will be created. Must be of this
form `org-project-env` to maintain a consistent naming for all resources. e.g. `msft-netcore-dev`

- `region`: The region where the infrastructure will be hosted. Zones are automatically assigned.

- `random_suffix`: Whether each created infrastructure resource name should have a random suffix to
support more dynamic naming. Default- false.

### k8s-cluster

A `kubernetes` cluster using Google Kubernetes Engine.

Example usage-

```
module "gke_cluster" {
	source = "./modules/gcp/k8s-cluster"
	gcp_project = var.gcp_project
	private_network = module.vpc.network
	private_subnet = module.vpc.subnet
	region = var.region
	random_suffix = var.random_suffix
	initial_node_count = var.initial_node_count
	max_node_count = var.max_node_count
	machine_type = var.node_machine_type
	disk_size = var.node_disk_size

	# kubernetes namespaces to create
	kubernetes_namespace_list = ["myts"]

	kubernetes_secrets = {
		"myts:mysql": {
			"host": module.mysql.master_private_ip_address
			"username": module.mysql.app_user_name,
			"password": module.mysql.app_user_password,
			"dbname": module.mysql.master_db_name
		}
	}
}
```

### mysql

A managed `mysql` instance using Google Cloud SQL.

Example usage-

```
module "mysql" {
	source = "./modules/gcp/mysql"
	gcp_project = var.gcp_project
	region = var.region
	random_suffix = var.random_suffix
	private_network = module.vpc.network
	num_read_replicas = 1
	machine_type = var.db_machine_type
}
```

### network

A private network creation module which is used by other resources.

Example usage-

```
module "vpc" {
	source = "./modules/gcp/network"
	gcp_project = var.gcp_project
	random_suffix = var.random_suffix
}
```

### firewall

Firewall rules for your private network in a cluster or infrastructure.

Example usage-

```
module "firewall" {
    source = "./modules/gcp/firewall"
    gcp_project = var.gcp_project
    network = var.vpc
    public_subnetwork = var.public_subnet
    private_subnetwork = var.private_subnet
}
```