output "instance_ids" {
  description = "Map of ECS keys to their instance IDs."
  value       = { for k, v in huaweicloud_compute_instance.this : k => v.id }
}

output "instance_private_ips" {
  description = "Map of ECS keys to their private IPv4 addresses."
  value       = { for k, v in huaweicloud_compute_instance.this : k => v.network[0].fixed_ip_v4 }
}

output "availability_zones" {
  description = "Map of ECS keys to their assigned availability zones."
  value       = { for k, v in var.ecs_instances : k => var.availability_zones[random_integer.az_index[k].result] }
}
