/* Local Variables */
locals {
    resource_group = var.resource_group
    vpc_subnet_ids = var.vpc_subnet_ids
    vpc_zones = var.vpc_zones

    vpc_name = var.vpc_name

    vpc_first_zone = length(local.vpc_zones) > 0 ? local.vpc_zones[0] : ""
    region = local.vpc_first_zone == "" ? "" : "${split("-",local.vpc_first_zone)[0]}-${split("-",local.vpc_first_zone)[1]}"

    firewall_ssh_key = var.firewall_ssh_key
    firewall_security_groups = var.firewall_security_groups

    health_check_fw_port = 8117
    firewall_version = var.firewall_version
    
    firewall_profile = var.firewall_profile
    firewall_prefix_name = var.firewall_prefix_name
    load_balancer_prefix_name = var.load_balancer_prefix_name

    load_balancer_public_ip = var.load_balancer_public_ip

    load_balancer_type = local.load_balancer_public_ip == true ? "public" : "private"
    load_balancer_route_mode = local.load_balancer_public_ip == true ? false : true

    tags = var.tags
}

data ibm_resource_group resource_group {
    name = local.resource_group
}

/* Firewall Checkpoint Module (for_each DC) */
module gateways {
    for_each = toset(local.vpc_zones)
    source = "github.com/marcosbv/checkpoint-iaas-cluster-ibm-vpc"
    VPC_Region = local.region
    VPC_Name = local.vpc_name
    Resource_Group = local.resource_group
    External_Subnet_ID = local.vpc_subnet_ids[index(local.vpc_zones, each.key)]
    CP_Version = local.firewall_version
    SSH_Key = local.firewall_ssh_key
    VNF_Security_Group = local.firewall_security_groups[index(local.vpc_zones, each.key)]
    VNF_Profile = local.firewall_profile
    VNF_CP-GW_Instance1 = "${local.firewall_prefix_name}-${each.key}-primary"
    VNF_CP-GW_Instance2 = "${local.firewall_prefix_name}-${each.key}-secondary"
    tags = local.tags
}

/* Network Load Balancer (for_each DC) */
resource ibm_is_lb load_balancer {
    for_each = toset(local.vpc_zones)
    name = "${local.load_balancer_prefix_name}-${each.key}"
    subnets = [local.vpc_subnet_ids[index(local.vpc_zones, each.key)]]
    // future attribute according to PR https://github.com/IBM-Cloud/terraform-provider-ibm/pull/3208
    route_mode = local.load_balancer_route_mode
    profile = "network-fixed"
    type = local.load_balancer_type
    resource_group = data.ibm_resource_group.resource_group.id
    tags = local.tags
}

/* Network Load Balancer Pool and Pool Members (for_each DC) */
resource ibm_is_lb_pool load_balancer_pool {
    for_each = toset(local.vpc_zones)
    name = "${local.load_balancer_prefix_name}-${each.key}-pool"
    lb = ibm_is_lb.load_balancer[each.key].id
    algorithm = "round_robin"
    protocol = "tcp"
    health_type = "tcp"
    health_monitor_port = local.health_check_fw_port
    health_retries = 3
    health_delay = 5
    health_timeout = 2
    session_persistence_type = "source_ip"
}

resource ibm_is_lb_pool_member load_balancer_primary_members {
   for_each = toset(local.vpc_zones)
   lb = ibm_is_lb.load_balancer[each.key].id
   pool = ibm_is_lb_pool.load_balancer_pool[each.key].id
   port = 443
   target_id = module.gateways[each.key].firewall_instance_ids[0]
}

resource ibm_is_lb_pool_member load_balancer_secondary_members {
   for_each = toset(local.vpc_zones)
   lb = ibm_is_lb.load_balancer[each.key].id
   pool = ibm_is_lb_pool.load_balancer_pool[each.key].id
   port = 443
   target_id = module.gateways[each.key].firewall_instance_ids[1]
}

/* Network Load Balancer Listener (for_each DC) */ 
resource ibm_is_lb_listener load_balancer_listener {
  for_each = toset(local.vpc_zones)
  lb       = ibm_is_lb.load_balancer[each.key].id
  //port     = 1
  // future parameters for PR https://github.com/IBM-Cloud/terraform-provider-ibm/pull/3207 (port_min and port_max will be calculated for routing mode)
  protocol = "tcp"
  default_pool = ibm_is_lb_pool.load_balancer_pool[each.key].pool_id
}