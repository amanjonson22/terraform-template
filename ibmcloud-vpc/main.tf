/*
* VPC Simple Module
*/

locals {
    vpc_name = var.vpc_name
    resource_group_id = var.rg_id
    region = var.region
    zone1 = "${local.region}-1"
    zone2 = "${local.region}-2"
    zone3 = "${local.region}-3"

    number_of_bits_ahead_subnet =  var.bits_ahead_subnet

    tags = var.tags

    address_prefixes_dc1 = var.address_prefixes[local.zone1]
    address_prefixes_dc2 = var.address_prefixes[local.zone2]
    address_prefixes_dc3 = var.address_prefixes[local.zone3]
    private_subnets = var.private_subnets

    subnets_dc1 = length(local.address_prefixes_dc1) > 0 ? local.private_subnets : []
    subnets_dc2 = length(local.address_prefixes_dc2) > 0 ? local.private_subnets : []
    subnets_dc3 = length(local.address_prefixes_dc3) > 0 ? local.private_subnets : []

    routing_tables_dc1 = var.routing_tables[local.zone1]
    routing_tables_dc2 = var.routing_tables[local.zone2]
    routing_tables_dc3 = var.routing_tables[local.zone3]
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
    zone = local.zone1
    vpc  = ibm_is_vpc.vpc.id
    cidr = each.key
}

/* Address prefixes (DC2) */
resource ibm_is_vpc_address_prefix address_prefix_dc2 {
    for_each = toset(local.address_prefixes_dc2)
    name = "vpc-address-prefix-${local.region}-dc2-${index(local.address_prefixes_dc2, each.key)}"
    zone = local.zone2
    vpc  = ibm_is_vpc.vpc.id
    cidr = each.key
}

/* Address prefixes (DC3) */
resource ibm_is_vpc_address_prefix address_prefix_dc3 {
    for_each = toset(local.address_prefixes_dc3)
    name = "vpc-address-prefix-${local.region}-dc3-${index(local.address_prefixes_dc3, each.key)}"
    zone = local.zone3
    vpc  = ibm_is_vpc.vpc.id
    cidr = each.key
}

/* Routing table (DC1) */
resource "ibm_is_vpc_routing_table" "routing_table_dc1" {
  vpc = ibm_is_vpc.vpc.id
  name = "routing-table-${local.zone1}"
  route_direct_link_ingress = false
  route_transit_gateway_ingress = false
  route_vpc_zone_ingress = false
}

resource "ibm_is_vpc_routing_table_route" "routes_dc1" {
  for_each = toset(local.routing_tables_dc1)
  vpc = ibm_is_vpc.vpc.id
  routing_table = ibm_is_vpc_routing_table.routing_table_dc1.routing_table
  zone = local.zone1
  name = "custom-route-${index(local.routing_tables_dc1, each.key)}"
  destination = split("-->", each.key)[0]
  action = split("-->", each.key)[1] == "vpc" ? "delegate_vpc" : "deliver"
  next_hop = split("-->", each.key)[1] == "vpc"? "0.0.0.0" : split("-->", each.key)[1] // Example value "10.0.0.4"
}
/* Routing table (DC2) */
resource "ibm_is_vpc_routing_table" "routing_table_dc2" {
  vpc = ibm_is_vpc.vpc.id
  name = "routing-table-${local.zone2}"
  route_direct_link_ingress = false
  route_transit_gateway_ingress = false
  route_vpc_zone_ingress = false
}

resource "ibm_is_vpc_routing_table_route" "routes_dc2" {
  for_each = toset(local.routing_tables_dc2)
  vpc = ibm_is_vpc.vpc.id
  routing_table = ibm_is_vpc_routing_table.routing_table_dc2.routing_table
  zone = local.zone2
  name = "custom-route-${index(local.routing_tables_dc2, each.key)}"
  destination = split("-->", each.key)[0]
  action = split("-->", each.key)[1] == "vpc" ? "delegate_vpc" : "deliver"
  next_hop = split("-->", each.key)[1] == "vpc"? "0.0.0.0" : split("-->", each.key)[1] // Example value "10.0.0.4"
}

/* Routing table (DC3) */

resource "ibm_is_vpc_routing_table" "routing_table_dc3" {
  vpc = ibm_is_vpc.vpc.id
  name = "routing-table-${local.zone3}"
  route_direct_link_ingress = false
  route_transit_gateway_ingress = false
  route_vpc_zone_ingress = false
}

resource "ibm_is_vpc_routing_table_route" "routes_dc3" {
  for_each = toset(local.routing_tables_dc3)
  vpc = ibm_is_vpc.vpc.id
  routing_table = ibm_is_vpc_routing_table.routing_table_dc3.routing_table
  zone = local.zone3
  name = "custom-route-${index(local.routing_tables_dc3, each.key)}"
  destination = split("-->", each.key)[0]
  action = split("-->", each.key)[1] == "vpc" ? "delegate_vpc" : "deliver"
  next_hop = split("-->", each.key)[1] == "vpc"? "0.0.0.0" : split("-->", each.key)[1] // Example value "10.0.0.4"
}

/*  Subnet (DC1)*/
resource ibm_is_subnet vpc_subnet_dc1 {
  depends_on = [
    ibm_is_vpc_address_prefix.address_prefix_dc1
  ]
  for_each =      toset(local.subnets_dc1)
  name            = "vpc-subnet-${local.region}-dc1-${each.key}"
  //public_gateway  = each.key == "public" ? true : false 
  vpc             = ibm_is_vpc.vpc.id
  zone = local.zone1
  ipv4_cidr_block = cidrsubnet(local.address_prefixes_dc1[0], local.number_of_bits_ahead_subnet, index(local.subnets_dc1, each.key))
  routing_table = ibm_is_vpc_routing_table.routing_table_dc1.routing_table
}

/*  Subnet (DC2)*/
resource ibm_is_subnet vpc_subnet_dc2 {
  depends_on = [
    ibm_is_vpc_address_prefix.address_prefix_dc2
  ]
  for_each =      toset(local.subnets_dc2)
  name            = "vpc-subnet-${local.region}-dc2-${each.key}"
 // public_gateway  = each.key == "public" ? true : false 
  vpc             = ibm_is_vpc.vpc.id
  zone = local.zone2
  ipv4_cidr_block = cidrsubnet(local.address_prefixes_dc2[0], local.number_of_bits_ahead_subnet, index(local.subnets_dc2, each.key))
  routing_table = ibm_is_vpc_routing_table.routing_table_dc2.routing_table
}

/*  Subnet (DC3)*/
resource ibm_is_subnet vpc_subnet_dc3 {
  depends_on = [
    ibm_is_vpc_address_prefix.address_prefix_dc3
  ]
  for_each =      toset(local.subnets_dc3)
  name            = "vpc-subnet-${local.region}-dc3-${each.key}"
//public_gateway  = each.key == "public" ? true : false 
  vpc             = ibm_is_vpc.vpc.id
  zone = local.zone3
  ipv4_cidr_block = cidrsubnet(local.address_prefixes_dc3[0], local.number_of_bits_ahead_subnet, index(local.subnets_dc3, each.key))
}
