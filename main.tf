###############################################################################
# Root composition: wires variables into the infrastructure modules.
###############################################################################

locals {
  # Common tags applied to every taggable resource.
  common_tags = merge(var.tags, { Environment = var.environment })
}

# Availability zones in the target region. Used to randomly assign an AZ to
# every resource that supports one (subnet, SFS Turbo, ECS, VPN gateway).
data "huaweicloud_availability_zones" "available" {}

# -----------------------------------------------------------------------------
# Network: VPC + Subnet
# -----------------------------------------------------------------------------
module "network" {
  source = "./modules/network"

  vpc_name          = var.vpc_name
  vpc_cidr          = var.vpc_cidr
  subnet_name       = var.subnet_name
  subnet_cidr       = var.subnet_cidr
  subnet_gateway_ip = var.subnet_gateway_ip

  availability_zones = data.huaweicloud_availability_zones.available.names

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Security: two security groups (database + ldap) + rules
# -----------------------------------------------------------------------------
module "security" {
  source = "./modules/security"

  database_sg_name        = var.database_sg_name
  database_sg_description = var.database_sg_description
  ldap_sg_name            = var.ldap_sg_name
  ldap_sg_description     = var.ldap_sg_description

  vpc_cidr = module.network.vpc_cidr

  enable_ssh      = var.enable_ssh
  ssh_source_cidr = var.ssh_source_cidr

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Storage: SFS Turbo file systems
# -----------------------------------------------------------------------------
module "storage" {
  source = "./modules/storage"

  sfs_turbo_instances = var.sfs_turbo_instances

  vpc_id            = module.network.vpc_id
  subnet_id         = module.network.subnet_id
  security_group_id = module.security.database_security_group_id

  availability_zones = data.huaweicloud_availability_zones.available.names

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Compute: ECS instances
#   Flavors are looked up by vCPU/memory, images by name, and AZs are randomly
#   assigned from the region's available zones.
# -----------------------------------------------------------------------------
module "compute" {
  source = "./modules/compute"

  ecs_instances       = var.ecs_instances
  ecs_admin_passwords = var.ecs_admin_passwords

  subnet_id                  = module.network.subnet_id
  database_security_group_id = module.security.database_security_group_id
  ldap_security_group_id     = module.security.ldap_security_group_id

  availability_zones = data.huaweicloud_availability_zones.available.names

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# VPN: public EIPs + VPN gateway
# -----------------------------------------------------------------------------
module "vpn" {
  source = "./modules/vpn"

  vpc_id    = module.network.vpc_id
  subnet_id = module.network.subnet_id

  vpn_gateway_name  = var.vpn_gateway_name
  vpn_flavor        = var.vpn_flavor
  vpn_ha_mode       = var.vpn_ha_mode
  vpn_local_subnets = var.vpn_local_subnets

  eip_type             = var.eip_type
  eip_charge_mode      = var.eip_charge_mode
  eip_1_bandwidth_name = var.eip_1_bandwidth_name
  eip_1_bandwidth_size = var.eip_1_bandwidth_size
  eip_2_bandwidth_name = var.eip_2_bandwidth_name
  eip_2_bandwidth_size = var.eip_2_bandwidth_size

  tags = local.common_tags
}
