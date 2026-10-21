###############################################################################
# VPN module: public EIPs + VPN gateway
#
# Two dedicated-bandwidth (share_type = "PER") EIPs are created and attached to
# the VPN gateway via the eip1 / eip2 blocks. The gateway availability zones are
# queried from the huaweicloud_vpn_gateway_availability_zones data source so
# only zones that actually support the requested flavor are used. Connection
# capacity is determined by the gateway flavor and is not a separate Terraform
# argument.
###############################################################################

# Availability zones that support the requested VPN gateway flavor.
data "huaweicloud_vpn_gateway_availability_zones" "this" {
  flavor          = lower(var.vpn_flavor)
  attachment_type = "vpc"
}

# EIP 1
resource "huaweicloud_vpc_eip" "eip_1" {
  publicip {
    type = var.eip_type
  }

  bandwidth {
    share_type  = "PER"
    name        = var.eip_1_bandwidth_name
    size        = var.eip_1_bandwidth_size
    charge_mode = var.eip_charge_mode
  }

  charging_mode = "postPaid" # pay-per-use

  tags = var.tags
}

# EIP 2
resource "huaweicloud_vpc_eip" "eip_2" {
  publicip {
    type = var.eip_type
  }

  bandwidth {
    share_type  = "PER"
    name        = var.eip_2_bandwidth_name
    size        = var.eip_2_bandwidth_size
    charge_mode = var.eip_charge_mode
  }

  charging_mode = "postPaid" # pay-per-use

  tags = var.tags
}

# VPN gateway
resource "huaweicloud_vpn_gateway" "this" {
  name           = var.vpn_gateway_name
  vpc_id         = var.vpc_id
  local_subnets  = var.vpn_local_subnets
  connect_subnet = var.subnet_id
  availability_zones = [
    data.huaweicloud_vpn_gateway_availability_zones.this.names[0],
    data.huaweicloud_vpn_gateway_availability_zones.this.names[1]
  ]
  flavor  = var.vpn_flavor
  ha_mode = var.vpn_ha_mode

  eip1 {
    id = huaweicloud_vpc_eip.eip_1.id
  }

  eip2 {
    id = huaweicloud_vpc_eip.eip_2.id
  }

  tags = var.tags
}
