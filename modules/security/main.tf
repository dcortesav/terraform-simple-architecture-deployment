###############################################################################
# Security module: application security group + rules
#
# Default rules are deleted so that all rules are managed explicitly here:
#   - ingress: all traffic from within the VPC (internal communication)
#   - egress:  all traffic (required once default rules are removed)
#   - ingress: SSH  (TCP 22)   -- optional, controlled by enable_ssh
#   - ingress: RDP  (TCP 3389) -- optional, controlled by enable_rdp
###############################################################################

resource "huaweicloud_networking_secgroup" "this" {
  name                 = var.security_group_name
  description          = var.security_group_description
  delete_default_rules = true

  tags = var.tags
}

# Allow all traffic originating from within the VPC.
resource "huaweicloud_networking_secgroup_rule" "internal_vpc" {
  security_group_id = huaweicloud_networking_secgroup.this.id
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = var.vpc_cidr
}

# Allow all egress traffic.
resource "huaweicloud_networking_secgroup_rule" "egress" {
  security_group_id = huaweicloud_networking_secgroup.this.id
  direction         = "egress"
  ethertype         = "IPv4"
}

# SSH ingress (TCP 22).
resource "huaweicloud_networking_secgroup_rule" "ssh" {
  count = var.enable_ssh ? 1 : 0

  security_group_id = huaweicloud_networking_secgroup.this.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.ssh_source_cidr
}

# RDP ingress (TCP 3389).
resource "huaweicloud_networking_secgroup_rule" "rdp" {
  count = var.enable_rdp ? 1 : 0

  security_group_id = huaweicloud_networking_secgroup.this.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3389
  port_range_max    = 3389
  remote_ip_prefix  = var.rdp_source_cidr
}
