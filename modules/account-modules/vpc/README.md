# vpc

## Usage

```hcl
module "vpc" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/account-modules/vpc"

  # ... see inputs below
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway_vpc_attachment.tgw_vpc_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.publicRouteTable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.publicRouteTableAssociation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.privateSubnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.publicSubnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_commonTransitGatwayId"></a> [commonTransitGatwayId](#input\_commonTransitGatwayId) | n/a | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `any` | n/a | yes |
| <a name="input_supportPublicSubnets"></a> [supportPublicSubnets](#input\_supportPublicSubnets) | n/a | `bool` | `false` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_privateSubnetIds"></a> [privateSubnetIds](#output\_privateSubnetIds) | n/a |
| <a name="output_privateSubnets"></a> [privateSubnets](#output\_privateSubnets) | n/a |
| <a name="output_publicSubnetIds"></a> [publicSubnetIds](#output\_publicSubnetIds) | n/a |
| <a name="output_transitGatewayAttachmentId"></a> [transitGatewayAttachmentId](#output\_transitGatewayAttachmentId) | n/a |
| <a name="output_vpcArn"></a> [vpcArn](#output\_vpcArn) | n/a |
| <a name="output_vpcCidr"></a> [vpcCidr](#output\_vpcCidr) | n/a |
| <a name="output_vpcId"></a> [vpcId](#output\_vpcId) | n/a |
<!-- END_TF_DOCS -->
