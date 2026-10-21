###############################################################################
# Provider / Global
###############################################################################

variable "access_key" {
  description = "Huawei Cloud access key (AK). Leave null to use the HW_ACCESS_KEY environment variable."
  type        = string
  sensitive   = true
  default     = null
}

variable "secret_key" {
  description = "Huawei Cloud secret key (SK). Leave null to use the HW_SECRET_KEY environment variable."
  type        = string
  sensitive   = true
  default     = null
}

variable "region" {
  description = "Huawei Cloud region where all resources will be created."
  type        = string
}

variable "project_id" {
  description = "Target project (tenant) ID / Enterprise Project ID."
  type        = string
}

variable "environment" {
  description = "Environment label applied to all resources via tags (e.g. production, staging)."
  type        = string
}

variable "tags" {
  description = "Additional common tags applied to all taggable resources."
  type        = map(string)
  default     = {}
}

###############################################################################
# Network
###############################################################################

variable "vpc_name" {
  description = "Name of the VPC."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC."
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet."
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block of the subnet (must be within the VPC CIDR)."
  type        = string
}

variable "subnet_gateway_ip" {
  description = "Gateway IP for the subnet."
  type        = string
}

###############################################################################
# Security
###############################################################################

variable "database_sg_name" {
  description = "Name of the database security group."
  type        = string
}

variable "database_sg_description" {
  description = "Description of the database security group."
  type        = string
}

variable "ldap_sg_name" {
  description = "Name of the LDAP security group."
  type        = string
}

variable "ldap_sg_description" {
  description = "Description of the LDAP security group."
  type        = string
}

variable "enable_ssh" {
  description = "Whether to create an SSH ingress rule (TCP 22) in both security groups."
  type        = bool
}

variable "ssh_source_cidr" {
  description = "Source CIDR allowed for SSH ingress. Defaults to 0.0.0.0/0 (anywhere); restrict to a narrower CIDR for production."
  type        = string
  default     = "0.0.0.0/0"
}

###############################################################################
# Storage (SFS Turbo)
###############################################################################

variable "sfs_turbo_instances" {
  description = <<-EOT
    Map of SFS Turbo file systems to create. Each entry must specify:
      name       - file system name (4-64 chars, must start with a letter, only
                   letters/digits/hyphens/underscores — no spaces or special chars)
      share_type - STANDARD or PERFORMANCE
      size       - capacity in GB (minimum 500 for STANDARD/PERFORMANCE)

    The availability zone is randomly assigned from the region's zones.
  EOT
  type = map(object({
    name       = string
    share_type = string
    size       = number
  }))

  validation {
    condition = alltrue([
      for k, v in var.sfs_turbo_instances :
      can(regex("^[A-Za-z][A-Za-z0-9_-]{3,63}$", v.name))
    ])
    error_message = "Each SFS Turbo name must start with a letter, be 4-64 characters, and contain only letters, digits, hyphens, and underscores (no spaces or special characters)."
  }
}

###############################################################################
# Compute (ECS)
###############################################################################

variable "ecs_instances" {
  description = <<-EOT
    Map of ECS instances to create. Each entry must specify:
      name              - instance name
      vcpu_count        - number of vCPUs (used to look up a matching flavor)
      memory_gb         - memory in GB (used to look up a matching flavor)
      image_name        - image name pattern (regex) used to look up the OS image
      system_disk_type  - system disk type (SSD, GPSSD, SAS, ESSD, ...)
      system_disk_size  - system disk size in GB
      fixed_ip          - static private IPv4 address within the subnet
    Optional fields:
      performance_type  - ECS flavor type to narrow the lookup (normal, computingv3,
                          highmem, saphana, diskintensive). Omit to search all types.
      key_pair          - name of an existing SSH key pair (use this OR a password)

    The availability zone, flavor ID, and image ID are resolved dynamically:
      - AZ    : randomly assigned from the region's availability zones
      - flavor: looked up by vCPU count + memory in the assigned AZ
      - image : looked up by name pattern (most recent public match)
  EOT
  type = map(object({
    name             = string
    vcpu_count       = number
    memory_gb        = number
    image_name       = string
    system_disk_type = string
    system_disk_size = number
    fixed_ip         = string
    performance_type = optional(string)
    key_pair         = optional(string)
  }))
}

variable "ecs_admin_passwords" {
  description = <<-EOT
    Sensitive map of ECS admin passwords, keyed by the same key used in
    `ecs_instances`. Set a password here for any instance that should log in
    with a password instead of a key pair. Omit an entry (or leave it empty)
    to use the key pair declared in `ecs_instances` instead.
  EOT
  type        = map(string)
  sensitive   = true
  default     = {}
}

###############################################################################
# VPN
###############################################################################

variable "vpn_gateway_name" {
  description = "Name of the VPN gateway."
  type        = string
}

variable "vpn_flavor" {
  description = "VPN gateway flavor: Basic, Professional1, Professional2 or GM."
  type        = string
}

variable "vpn_ha_mode" {
  description = "HA mode of the VPN gateway: active-active or active-standby."
  type        = string
}

variable "vpn_local_subnets" {
  description = "List of local subnet CIDRs advertised by the VPN gateway."
  type        = list(string)
}

variable "eip_type" {
  description = "EIP type for the VPN gateway public IPs: 5_bgp (dynamic) or 5_sbgp (static)."
  type        = string
}

variable "eip_charge_mode" {
  description = "Bandwidth billing mode for the VPN EIPs: traffic or bandwith."
  type        = string
}

variable "eip_1_bandwidth_name" {
  description = "Bandwidth name for the first VPN EIP."
  type        = string
}

variable "eip_1_bandwidth_size" {
  description = "Dedicated bandwith size (Mbit/s) for the first VPN EIP."
  type        = number
}

variable "eip_2_bandwidth_name" {
  description = "Bandwidth name for the second VPN EIP."
  type        = string
}

variable "eip_2_bandwidth_size" {
  description = "Dedicated bandwith size (Mbit/s) for the second VPN EIP."
  type        = number
}
