# attach to the routing transit gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attachment" {
  transit_gateway_id = var.commonTransitGatwayId
  vpc_id             = aws_vpc.vpc.id
  subnet_ids         = [for subnet in aws_subnet.privateSubnets : subnet.id]

  tags = {
    Name = var.name
  }
}

# Create route tables for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.commonTransitGatwayId
  }

  tags = {
    Name = "${var.name}-private-route-table"
  }
}

# Associate private subnets with the nearest NAT Gateway
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.privateSubnets)
  subnet_id      = aws_subnet.privateSubnets[count.index].id
  route_table_id = aws_route_table.private.id # Distribute subnets across two NAT Gateways
}
