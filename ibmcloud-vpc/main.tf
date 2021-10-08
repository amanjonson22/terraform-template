/*
* VPC Simple Module
*/

locals {
    vpc_name = var.vpc_name
    resource_group_id = var.rg_id
    vpc_subnet = var.vpc_subnet
    region = var.region
    number_of_datacenters = var.number_of_datacenters
    number_of_splits = var.number_of_splits
    number_of_bits_ahead_subnet = local.number_of_splits + var.bits_ahead_subnet

    tags = var.tags

    address_prefixes_dc1 = local.number_of_datacenters == 3 ? [cidrsubnet(local.vpc_subnet, local.number_of_splits, 0), cidrsubnet(cidrsubnet(local.vpc_subnet, local.number_of_splits, 3), 1, 0)] : [cidrsubnet(local.vpc_subnet, local.number_of_splits, 0)]
    address_prefixes_dc2 = local.number_of_datacenters == 3 ? [cidrsubnet(local.vpc_subnet, local.number_of_splits, 1), cidrsubnet(cidrsubnet(local.vpc_subnet, local.number_of_splits, 3), 2, 2)] : [cidrsubnet(local.vpc_subnet, local.number_of_splits, 1)]
    address_prefixes_dc3 = local.number_of_datacenters == 3 ? [cidrsubnet(local.vpc_subnet, local.number_of_splits, 2), cidrsubnet(cidrsubnet(local.vpc_subnet, local.number_of_splits, 3), 2, 3)] : []
}

resource ibm_is_vpc vpc {
   name = local.vpc_name
   address_prefix_management = "manual"
   resource_group = local.resource_group_id
   tags = local.tags
}

/* Address prefixes (DC1) */
resource ibm_is_vpc_address_prefix address_prefix_dc1 {
    for_each = toset(local.address_prefixes_dc1)
    name = "vpc-address-prefix-${local.region}-dc1-${index(local.address_prefixes_dc1, each.key)}"
    zone = "${local.region}-1"
    vpc  = ibm_is_vpc.vpc.id
    cidr = each.key
}

/* Address prefixes (DC2) */
resource ibm_is_vpc_address_prefix address_prefix_dc2 {
    for_each = toset(local.address_prefixes_dc2)
    name = "vpc-address-prefix-${local.region}-dc2-${index(local.address_prefixes_dc2, each.key)}"
    zone = "${local.region}-2"
    vpc  = ibm_is_vpc.vpc.id
    cidr = each.key
}

/* Address prefixes (DC3) */
resource ibm_is_vpc_address_prefix address_prefix_dc3 {
    for_each = toset(local.address_prefixes_dc3)
    name = "vpc-address-prefix-${local.region}-dc3-${index(local.address_prefixes_dc3, each.key)}"
    zone = "${local.region}-3"
    vpc  = ibm_is_vpc.vpc.id
    cidr = each.key
}

/*  Subnet (DC1)*/
resource ibm_is_subnet vpc_subnet_dc1 {
  depends_on = [
    ibm_is_vpc_address_prefix.address_prefix_dc1
  ]
  for_each = toset(local.address_prefixes_dc1)
  name            = "vpc-subnet-${local.region}-dc1-${index(local.address_prefixes_dc1, each.key)}"
  vpc             = ibm_is_vpc.vpc.id
  zone = "${local.region}-1"
  ipv4_cidr_block = cidrsubnet(each.key, local.number_of_bits_ahead_subnet, 0)
}

/*  Subnet (DC2)*/
resource ibm_is_subnet vpc_subnet_dc2 {
  depends_on = [
    ibm_is_vpc_address_prefix.address_prefix_dc2
  ]
  for_each = toset(local.address_prefixes_dc2)
  name            = "vpc-subnet-${local.region}-dc2-${index(local.address_prefixes_dc2, each.key)}"
  vpc             = ibm_is_vpc.vpc.id
  zone = "${local.region}-2"
  ipv4_cidr_block = cidrsubnet(each.key, local.number_of_bits_ahead_subnet, 0)
}

/*  Subnet (DC3)*/
resource ibm_is_subnet vpc_subnet_dc3 {
  depends_on = [
    ibm_is_vpc_address_prefix.address_prefix_dc3
  ]
  for_each = toset(local.address_prefixes_dc3)
  name            = "vpc-subnet-${local.region}-dc3-${index(local.address_prefixes_dc3, each.key)}"
  vpc             = ibm_is_vpc.vpc.id
  zone = "${local.region}-3"
  ipv4_cidr_block = cidrsubnet(each.key, local.number_of_bits_ahead_subnet, 0)
}
