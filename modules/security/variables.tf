variable "security_group_name" {
  description = "Name of the security group."
  type        = string
}

variable "security_group_description" {
  description = "Description of the security group."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block, used to allow internal VPC traffic."
  type        = string
}

variable "enable_ssh" {
  description = "Whether to create an SSH ingress rule (TCP 22)."
  type        = bool
}

variable "ssh_source_cidr" {
  description = "Source CIDR for SSH ingress."
  type        = string
  default     = "0.0.0.0/0"
}

variable "enable_rdp" {
  description = "Whether to create an RDP ingress rule (TCP 3389)."
  type        = bool
}

variable "rdp_source_cidr" {
  description = "Source CIDR for RDP ingress."
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
