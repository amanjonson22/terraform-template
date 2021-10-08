locals {
    bgp_asn = var.bgp_asn
    dl_global = var.dl_global
    dl_metered = var.dl_metered
    dl_name = var.dl_name
    resource_group_networking = var.rg_id
    dl_speed = var.dl_speed
    cross_connect_router = var.cross_connect_router
    dl_location_name = var.dl_location_name
    dl_customer_name = var.dl_customer_name
    dl_carrier_name = var.dl_carrier_name
    vpc_crn = var.vpc_crn

    bgp_ibm_cidr = var.bgp_cidr != "" ? cidrsubnet(var.bgp_cidr,1,0) : null
    bgp_cer_cidr = var.bgp_cidr != "" ? cidrsubnet(var.bgp_cidr,1,1) : null

    tags = var.tags
}

resource ibm_dl_gateway direct_link_20 {
  bgp_asn = local.bgp_asn
  global =  local.dl_global
  metered = local.dl_metered
  name =    "${local.dl_name}_${replace(local.cross_connect_router,".","_")}"
  resource_group = local.resource_group_networking
  speed_mbps = local.dl_speed
  type =  "dedicated" 
  cross_connect_router = local.cross_connect_router
  location_name = local.dl_location_name
  customer_name = local.dl_customer_name 
  carrier_name = local.dl_carrier_name
  bgp_ibm_cidr = local.bgp_ibm_cidr
  bgp_cer_cidr = local.bgp_cer_cidr
  tags = local.tags
} 

// Connection Direct Link 2.0 X Classic Infrastructure
resource ibm_dl_virtual_connection dl_gateway_xcr_classic {
    gateway = ibm_dl_gateway.direct_link_20.id
    name = "${replace(local.cross_connect_router,".","_")}_Classic"
    type = "classic"
} 

// Connection Direct Link 2.0 X Hub VPC 
resource ibm_dl_virtual_connection dl_gateway_xcr_vpc {
    gateway = ibm_dl_gateway.direct_link_20.id
    name = "${replace(local.cross_connect_router,".","_")}_Hub"
    network_id = local.vpc_crn
    type = "vpc"
}  

