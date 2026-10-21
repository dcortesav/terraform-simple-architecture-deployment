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
  description = "CIDR block of the subnet."
  type        = string
}

variable "subnet_gateway_ip" {
  description = "Gateway IP for the subnet."
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones in the target region."
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
