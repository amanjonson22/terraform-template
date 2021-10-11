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
    default = "br-sao"
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
       "br-sao-1" =[],
       "br-sao-2" = [],
       "br-sao-3" = []
    }
    description = "List of routing tables per datacenter. Each entry will be a map like this example: {cidr = '192.168.0.1/24' route_to = '192.168.0.254 or vpc to delegate to vpc'}"
}
