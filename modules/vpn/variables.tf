variable "vpc_id" {
  description = "ID of the VPC."
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet used as the VPN gateway connect subnet."
  type        = string
}

variable "vpn_gateway_name" {
  description = "Name of the VPN gateway."
  type        = string
}

variable "vpn_flavor" {
  description = "VPN gateway flavor: Basic, Professional1, Professional2 or GM."
  type        = string
}

variable "vpn_ha_mode" {
  description = "HA mode: active-active or active-standby."
  type        = string
}

variable "vpn_local_subnets" {
  description = "List of local subnet CIDRs for the VPN gateway."
  type        = list(string)
}

variable "eip_type" {
  description = "EIP type: 5_bgp or 5_sbgp."
  type        = string
}

variable "eip_charge_mode" {
  description = "Bandwidth charge mode: traffic or bandwith."
  type        = string
}

variable "eip_1_bandwidth_name" {
  description = "Bandwidth name for EIP 1."
  type        = string
}

variable "eip_1_bandwidth_size" {
  description = "Bandwidth size (Mbit/s) for EIP 1."
  type        = number
}

variable "eip_2_bandwidth_name" {
  description = "Bandwidth name for EIP 2."
  type        = string
}

variable "eip_2_bandwidth_size" {
  description = "Bandwidth size (Mbit/s) for EIP 2."
  type        = number
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
