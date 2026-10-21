###############################################################################
# Security module: two security groups (database + ldap) with explicit rules
#
# dataBase-sg — database service ports (MySQL, MongoDB, PostgreSQL, Redis) from
#   the VPC, plus NFS (2049) for SFS Turbo access.
# ldap-sg     — LDAP port 389 from the VPC + ICMP from anywhere.
# Both SGs    — SSH (TCP 22) from a configurable CIDR, all egress, and full
#   intra-group communication (any protocol/port from instances in the same SG).
#
# Default rules are deleted so every rule is managed explicitly here.
###############################################################################

# --- Security groups -----------------------------------------------------------

resource "huaweicloud_networking_secgroup" "database" {
  name                 = var.database_sg_name
  description          = var.database_sg_description
  delete_default_rules = true

  tags = var.tags
}

resource "huaweicloud_networking_secgroup" "ldap" {
  name                 = var.ldap_sg_name
  description          = var.ldap_sg_description
  delete_default_rules = true

  tags = var.tags
}

# --- Common rules (both security groups) ---------------------------------------

# Egress: all traffic.
resource "huaweicloud_networking_secgroup_rule" "database_egress" {
  security_group_id = huaweicloud_networking_secgroup.database.id
  direction         = "egress"
  ethertype         = "IPv4"
}

resource "huaweicloud_networking_secgroup_rule" "ldap_egress" {
  security_group_id = huaweicloud_networking_secgroup.ldap.id
  direction         = "egress"
  ethertype         = "IPv4"
}

# SSH ingress (TCP 22).
resource "huaweicloud_networking_secgroup_rule" "database_ssh" {
  count = var.enable_ssh ? 1 : 0

  security_group_id = huaweicloud_networking_secgroup.database.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.ssh_source_cidr
}

resource "huaweicloud_networking_secgroup_rule" "ldap_ssh" {
  count = var.enable_ssh ? 1 : 0

  security_group_id = huaweicloud_networking_secgroup.ldap.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.ssh_source_cidr
}

# Intra-group: allow all ingress from instances in the same security group.
resource "huaweicloud_networking_secgroup_rule" "database_intra" {
  security_group_id = huaweicloud_networking_secgroup.database.id
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = huaweicloud_networking_secgroup.database.id
}

resource "huaweicloud_networking_secgroup_rule" "ldap_intra" {
  security_group_id = huaweicloud_networking_secgroup.ldap.id
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = huaweicloud_networking_secgroup.ldap.id
}

# --- dataBase-sg specific rules ------------------------------------------------

# Database service ports from the VPC (see sg-ports.md).
resource "huaweicloud_networking_secgroup_rule" "database_ports" {
  for_each = toset(["3306", "3307", "3308", "3316", "33060", "33070", "33080", "27017", "5432", "6379", "6380"])

  security_group_id = huaweicloud_networking_secgroup.database.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = tonumber(each.key)
  port_range_max    = tonumber(each.key)
  remote_ip_prefix  = var.vpc_cidr
}

# NFS (TCP 2049) from the VPC — required for SFS Turbo access by all instances.
resource "huaweicloud_networking_secgroup_rule" "database_nfs" {
  security_group_id = huaweicloud_networking_secgroup.database.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2049
  port_range_max    = 2049
  remote_ip_prefix  = var.vpc_cidr
}

# --- ldap-sg specific rules ----------------------------------------------------

# LDAP port 389 from the VPC.
resource "huaweicloud_networking_secgroup_rule" "ldap_port" {
  security_group_id = huaweicloud_networking_secgroup.ldap.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 389
  port_range_max    = 389
  remote_ip_prefix  = var.vpc_cidr
}

# ICMP from all IPv4 addresses.
resource "huaweicloud_networking_secgroup_rule" "ldap_icmp" {
  security_group_id = huaweicloud_networking_secgroup.ldap.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
}
