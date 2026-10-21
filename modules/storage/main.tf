###############################################################################
# Storage module: SFS Turbo file systems
###############################################################################

# Random availability zone index per file system.
resource "random_integer" "az_index" {
  for_each = var.sfs_turbo_instances

  min = 0
  max = length(var.availability_zones) - 1
}

resource "huaweicloud_sfs_turbo" "this" {
  for_each = var.sfs_turbo_instances

  name              = each.value.name
  size              = each.value.size
  share_type        = each.value.share_type
  share_proto       = "NFS"
  charging_mode     = "postPaid" # pay-per-use
  availability_zone = var.availability_zones[random_integer.az_index[each.key].result]

  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  security_group_id = var.security_group_id

  tags = var.tags
}
