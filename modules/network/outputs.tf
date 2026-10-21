output "vpc_id" {
  description = "ID of the VPC."
  value       = huaweicloud_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = huaweicloud_vpc.this.cidr
}

output "subnet_id" {
  description = "ID of the subnet."
  value       = huaweicloud_vpc_subnet.this.id
}

output "subnet_availability_zone" {
  description = "Availability zone assigned to the subnet."
  value       = var.availability_zones[random_integer.subnet_az.result]
}
