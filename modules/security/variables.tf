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

variable "vpc_cidr" {
  description = "VPC CIDR block, used to allow internal VPC traffic on service ports."
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

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
