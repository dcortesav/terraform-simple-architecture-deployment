output "vpn_gateway_id" {
  description = "ID of the VPN gateway."
  value       = huaweicloud_vpn_gateway.this.id
}

output "eip_addresses" {
  description = "Public EIP addresses assigned to the VPN gateway."
  value = {
    eip_1 = huaweicloud_vpc_eip.eip_1.address
    eip_2 = huaweicloud_vpc_eip.eip_2.address
  }
}

output "availability_zones" {
  description = "Availability zones assigned to the VPN gateway (queried from the VPN gateway AZ data source)."
  value       = data.huaweicloud_vpn_gateway_availability_zones.this.names
}
