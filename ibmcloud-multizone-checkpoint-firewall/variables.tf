variable ibmcloud_api_key{}

variable vpc_zones {
    type = list(string)
    description = "List of zones to apply this Checkpoint Active/Active firewall."
}

variable vpc_name {
    type = string
    description = "VPC Name to deploy the firewalls into."
}

variable vpc_subnet_ids {
    type = list(string)
    description = "List of subnet IDs to apply this Checkpoint Active/Active firewall."
}

variable resource_group {
    description = "Name of resource group to insert the firewall resources into."
}

variable firewall_ssh_key {
    description = "SSH Key Name created in VPC to insert into the firewalls."
}

variable firewall_security_groups {
    type = list(string)
    description = "List of security groups for the created firewalls."
}

variable firewall_profile {
    default = "cx2-8x16"
    description = "Machine profile for the firewalls." 
}

variable firewall_prefix_name {
    description = "Prefix name to be used for the firewalls to be deployed."
     default = "fw-checkpoint"
}
variable load_balancer_public_ip {
    type = bool
    default = false
    description = "True if load balancers should be created by using public IPs."
}

variable load_balancer_prefix_name {
    description = "Prefix name for the load balancer."
    default = "lb-diti"
}

variable tags {
    type = list(string)
    default = []
    description = "Tags to insert on provisioned resources"
}

variable firewall_version {
    default = "R81"
    description = "Checkpoint firewall version to deploy (R8040/R81)"
}