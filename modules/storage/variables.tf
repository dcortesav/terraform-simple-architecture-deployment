variable "sfs_turbo_instances" {
  description = "Map of SFS Turbo file systems to create."
  type = map(object({
    name       = string
    share_type = string
    size       = number
  }))
}

variable "availability_zones" {
  description = "List of availability zones in the target region."
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC."
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet."
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
