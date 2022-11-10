variable ibmcloud_api_key {}

variable vpc_name {
    description = "Name of VPC"
}

variable rg_id {
    description = "Resource Group ID to be used"
}

variable vpc_subnet {
    description = "CIDR of an entire VPC"
}

variable region {
    description = "Region to deploy"
    default = "us-south"
}

variable bits_ahead_subnet {
    type = number
    description = "Number of bits for a subnet related to address prefix (i.e: if address_prefix is a /24 and this variable is 2, the subnet will be created as /26)"
}

variable tags {
    type = list(string)
    default = []
    description = "Tags to be used in the VPC objects"
}

variable private_subnets {
    type = list(string)
    default = []
    description = "Name of private subnets to create. They will be allocated in the first address prefix."
}

variable address_prefixes {
    type = map(list(string))
    description = "Set of address prefixes to set to the datacenter regions."
}

variable routing_tables {
    type = map(list(string))
    default = {
       "us-south-1" =[],
       "us-south-2" = [],
       "us-south-3" = []
    }
    description = "List of routing tables per datacenter. Each entry will be a map like this example: {cidr = '192.168.0.1/24' route_to = '192.168.0.254 or vpc to delegate to vpc'}"
}

variable routing_tables_by_subnet {
    type = bool
    default = false
    description = "Flag to identify if the routes must be done by subnet (true) or by data center (false)"
}

variable cos_instance {
    description = "COS instance to configure Flow Logs"
    default = ""
}

variable cos_bucket {
    description = "COS bucket to configure Flow Logs"
    default = ""
}

variable flow_logs {
    description = "Enable flow logs at VPC level"
    type = bool
    default = false
}

variable cos_resource_group_id {
    description = "Resource group for COS instance (Flow Logs)"
    default = ""
}
