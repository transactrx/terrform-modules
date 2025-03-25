variable "name" {
}
variable "vpc_cidr_block" {
  type = string
}
variable "commonTransitGatwayId" {
  type = string
}

variable "supportPublicSubnets" {
  type    = bool
  default = false
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.name
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}


locals {
  numberOfAzs = length(data.aws_availability_zones.available.names)

  # Private subnets /24 - Largest allocation
  privateSubnetsRanges = [for i in range(1, local.numberOfAzs + 1) :
    cidrsubnet(aws_vpc.vpc.cidr_block, 4, i)
  ]

  # Public subnets /28 - Offset to start after private subnets
  publicSubnetsRanges = [for i in range(0, local.numberOfAzs) :
    cidrsubnet(aws_vpc.vpc.cidr_block, 8, local.numberOfAzs + i)
  ]

  # TGW subnets /28 - Offset to start after public subnets
  # tgwSubnetsRanges = [for i in range(0, local.numberOfAzs) :
  #   cidrsubnet(aws_vpc.vpc.cidr_block, 8, (2 * local.numberOfAzs) + i)
  # ]

  accountName = var.name
}

resource "aws_subnet" "privateSubnets" {
  count             = length(local.privateSubnetsRanges)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.privateSubnetsRanges[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "private${(count.index + 1)}"
  }
}

resource "aws_subnet" "publicSubnets" {
  count             = var.supportPublicSubnets ? length(local.publicSubnetsRanges) : 0
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.publicSubnetsRanges[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name    = "public${(count.index + 1)}"
    Network = "Public"
  }
}


resource "aws_internet_gateway" "igw" {
  count  = var.supportPublicSubnets ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.name}-IG"
  }
}

resource "aws_route_table" "publicRouteTable" {
  count  = var.supportPublicSubnets ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }
  tags = {
    Name="${var.name}-public-route-table"
  }
}

resource "aws_route_table_association" "publicRouteTableAssociation" {
  count          = var.supportPublicSubnets ? length(aws_subnet.publicSubnets) : 0
  subnet_id      = aws_subnet.publicSubnets[count.index].id
  route_table_id = aws_route_table.publicRouteTable[0].id
}
