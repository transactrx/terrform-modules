output "privateSubnetIds" {
  value = aws_subnet.privateSubnets[*].id
}
output "publicSubnetIds" {
  value = aws_subnet.publicSubnets[*].id
}
output "privateSubnets" {
  value = aws_subnet.privateSubnets
}
output "vpcId" {
  value = aws_vpc.vpc.id
}
output "vpcCidr" {
  value = aws_vpc.vpc.cidr_block
}

output "vpcArn" {
  value = aws_vpc.vpc.arn
}
output "transitGatewayAttachmentId" {
  value = aws_ec2_transit_gateway_vpc_attachment.tgw_vpc_attachment.id
}
