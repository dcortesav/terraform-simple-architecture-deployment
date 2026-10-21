###############################################################################
# Compute module: ECS instances
#
# For each instance:
#   - an availability zone is randomly assigned from the region's zones
#   - a flavor is looked up by vCPU count + memory in that AZ
#   - an image is looked up by name pattern (most recent public match)
# The VPC is implied by the subnet. Static private IPs use fixed_ip_v4.
###############################################################################

# Random availability zone index per instance.
resource "random_integer" "az_index" {
  for_each = var.ecs_instances

  min = 0
  max = length(var.availability_zones) - 1
}

# Look up a matching flavor per instance (by AZ, vCPU count and memory).
data "huaweicloud_compute_flavors" "this" {
  for_each = var.ecs_instances

  availability_zone = var.availability_zones[random_integer.az_index[each.key].result]
  cpu_core_count    = each.value.vcpu_count
  memory_size       = each.value.memory_gb
  performance_type  = each.value.performance_type
}

# Look up the OS image per instance (by name pattern, most recent public image).
data "huaweicloud_images_image" "this" {
  for_each = var.ecs_instances

  name_regex  = each.value.image_name
  visibility  = "public"
  most_recent = true
}

resource "huaweicloud_compute_instance" "this" {
  for_each = var.ecs_instances

  name              = each.value.name
  flavor_id         = data.huaweicloud_compute_flavors.this[each.key].ids[0]
  image_id          = data.huaweicloud_images_image.this[each.key].id
  availability_zone = var.availability_zones[random_integer.az_index[each.key].result]
  charging_mode     = "postPaid" # pay-per-use

  system_disk_type = each.value.system_disk_type
  system_disk_size = each.value.system_disk_size

  security_group_ids = [var.security_group_id]

  network {
    uuid        = var.subnet_id
    fixed_ip_v4 = each.value.fixed_ip
  }

  # Use either a password (from the sensitive ecs_admin_passwords map) or a key
  # pair. Both are optional; set one per instance.
  admin_pass = try(var.ecs_admin_passwords[each.key], null)
  key_pair   = each.value.key_pair

  delete_disks_on_termination = true

  tags = var.tags
}
