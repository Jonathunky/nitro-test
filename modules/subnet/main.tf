variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_prefix" {
  description = "CIDR prefix for subnets"
  default     = "10.0."
}

variable "subnet_count" {
  description = "Number of subnets"
  default     = 2
}

variable "subnet_mask" {
  description = "Subnet mask"
  default     = "8"
  # to get 16 + 8 = /24
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "Primary VPC"
  }
}

resource "aws_subnet" "my_subnet" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.my_vpc.cidr_block, var.subnet_mask, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

}

output "subnet_cidr_blocks" {
  value = aws_subnet.my_subnet[*].cidr_block
}

output "subnet_ids" {
  value = aws_subnet.my_subnet[*].id
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}
