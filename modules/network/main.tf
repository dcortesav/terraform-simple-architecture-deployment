###############################################################################
# Network module: VPC + subnet
###############################################################################

resource "huaweicloud_vpc" "this" {
  name = var.vpc_name
  cidr = var.vpc_cidr

  tags = var.tags
}

# Randomly pick an availability zone index for the subnet.
resource "random_integer" "subnet_az" {
  min = 0
  max = length(var.availability_zones) - 1
}

resource "huaweicloud_vpc_subnet" "this" {
  name       = var.subnet_name
  cidr       = var.subnet_cidr
  gateway_ip = var.subnet_gateway_ip
  vpc_id     = huaweicloud_vpc.this.id

  availability_zone = var.availability_zones[random_integer.subnet_az.result]

  tags = var.tags
}
