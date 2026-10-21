variable "ecs_instances" {
  description = "Map of ECS instances to create."
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
  description = "Sensitive map of ECS admin passwords, keyed by ecs_instances key."
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "availability_zones" {
  description = "List of availability zones in the target region."
  type        = list(string)
}

variable "subnet_id" {
  description = "ID of the subnet."
  type        = string
}

variable "database_security_group_id" {
  description = "ID of the database security group (assigned to all instances except LDAP)."
  type        = string
}

variable "ldap_security_group_id" {
  description = "ID of the LDAP security group (assigned to instances whose name is 'LDAP')."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
