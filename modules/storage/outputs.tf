output "sfs_turbo_ids" {
  description = "Map of SFS Turbo keys to their IDs."
  value       = { for k, v in huaweicloud_sfs_turbo.this : k => v.id }
}

output "sfs_turbo_export_locations" {
  description = "Map of SFS Turbo keys to their mount locations."
  value       = { for k, v in huaweicloud_sfs_turbo.this : k => v.export_location }
}

output "availability_zones" {
  description = "Map of SFS Turbo keys to their assigned availability zones."
  value       = { for k, v in var.sfs_turbo_instances : k => var.availability_zones[random_integer.az_index[k].result] }
}
