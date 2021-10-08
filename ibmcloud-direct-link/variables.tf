variable ibmcloud_api_key{}

variable dl_name {
   description = "Name of Direct Link instance"
}

variable dl_global {
    type = bool
    default = true
    description = "Global Routing DL (true) or Local Routing DL (false)"
}

variable dl_metered {
    type = bool
    default = true
    description = "True to be metered by GB, false to be metered in a flat rate"
}

variable rg_id {
    description = "Resource group ID to attach this Direct Link to"
}

variable dl_speed {
     description = "Direct Link speed, in Mbps"
}

variable cross_connect_router {
     description = "XCR Router Name"
}

variable dl_location_name {
    description = "Direct Link datacenter location (sao01)"
    default = "sao01"
}

variable dl_customer_name {
    description = "Customer Name"
}

variable dl_carrier_name {
    description = "Carrier Name"
}

variable bgp_asn {
    description = "BGP ASN to use"
}

variable bgp_cidr {
    description = "BGP CIDR to use for this DL connection. This Terraform script will automatically split between IBM XCR and Customer Router."
}

variable tags {
    type = list(string)
    default = []
}

variable vpc_crn {
    description = "CRN of a previously created VPC to attach to this Direct Link"
}