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

variable number_of_datacenters {
    description = "Number of availability zones to provision the VPC"
    type = number
    validation {
        condition = var.number_of_datacenters <= 3
        error_message = "The maximum of availability zones is 3."
    }
}

variable bits_ahead_subnet {
    type = number
    description = "Number of bits for a subnet related to address prefix (i.e: if address_prefix is a /24 and this variable is 2, the subnet will be created as /26)"
}


