###############################################################################
# Root outputs
###############################################################################

output "vpc_id" {
  description = "ID of the created VPC."
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the created VPC."
  value       = module.network.vpc_cidr
}

output "subnet_id" {
  description = "ID of the created subnet."
  value       = module.network.subnet_id
}

output "subnet_availability_zone" {
  description = "Availability zone randomly assigned to the subnet."
  value       = module.network.subnet_availability_zone
}

output "database_security_group_id" {
  description = "ID of the database security group."
  value       = module.security.database_security_group_id
}

output "ldap_security_group_id" {
  description = "ID of the LDAP security group."
  value       = module.security.ldap_security_group_id
}

output "sfs_turbo_ids" {
  description = "Map of SFS Turbo instance keys to their IDs."
  value       = module.storage.sfs_turbo_ids
}

output "sfs_turbo_export_locations" {
  description = "Map of SFS Turbo instance keys to their mount locations."
  value       = module.storage.sfs_turbo_export_locations
}

output "sfs_turbo_availability_zones" {
  description = "Map of SFS Turbo keys to their randomly assigned availability zones."
  value       = module.storage.availability_zones
}

output "ecs_instance_ids" {
  description = "Map of ECS instance keys to their IDs."
  value       = module.compute.instance_ids
}

output "ecs_instance_private_ips" {
  description = "Map of ECS instance keys to their private IPv4 addresses."
  value       = module.compute.instance_private_ips
}

output "ecs_availability_zones" {
  description = "Map of ECS keys to their randomly assigned availability zones."
  value       = module.compute.availability_zones
}

output "vpn_gateway_id" {
  description = "ID of the VPN gateway."
  value       = module.vpn.vpn_gateway_id
}

output "vpn_eip_addresses" {
  description = "Public EIP addresses assigned to the VPN gateway."
  value       = module.vpn.eip_addresses
}

output "vpn_availability_zones" {
  description = "Availability zones randomly assigned to the VPN gateway."
  value       = module.vpn.availability_zones
}
