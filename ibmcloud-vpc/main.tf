/*
* VPC Simple Module
*/

locals {
    vpc_name = var.vpc_name
    resource_group_id = var.rg_id
    vpc_subnet = var.vpc_subnet
    region = var.region
    number_of_datacenters = var.number_of_datacenters
    number_of_splits = 2
    number_of_bits_ahead_subnet = number_of_splits + var.bits_ahead_subnet
    transit_gateway_connections = var.transit_gateway_connections
}

resource ibm_is_vpc vpc {
   name = local.vpc_name
   address_prefix_management = "manual"
   resource_group = data.ibm_resource_group.resource_group.id
}

/* Address prefixes (one for each datacenter) */
resource ibm_is_vpc_address_prefix address_prefix {
    count = local.number_of_datacenters
    name = "vpc-address-prefix-${local.region}-${count}"
    zone = "${local.region}-${count}"
    vpc  = ibm_is_vpc.vpc.id
    cidr = cidrsubnet(local.vpc_subnet, local.number_of_splits, count)
}

/*  Subnet (the same )*/
resource ibm_is_subnet vpc_subnet {
  count = local.number_of_datacenters
  name            = "vpc-hub-subnet-${local.region}-${count}"
  vpc             = ibm_is_vpc.vpc.id
  zone = "${local.region}-${count}"
  ipv4_cidr_block = cidrsubnet(local.vpc_subnet, local.number_of_bits_ahead_subnet, count)
}
