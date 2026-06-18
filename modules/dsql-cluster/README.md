# dsql-cluster

Aurora DSQL cluster module.

## Usage

```hcl
module "dsql" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/dsql-cluster"

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
| [aws_dsql_cluster.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dsql_cluster) | resource |
| [aws_dsql_cluster.secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dsql_cluster) | resource |
| [aws_dsql_cluster_peering.primary_to_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dsql_cluster_peering) | resource |
| [aws_dsql_cluster_peering.secondary_to_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dsql_cluster_peering) | resource |
| [aws_ssm_parameter.primary_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.secondary_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deletion_protection_enabled"></a> [deletion\_protection\_enabled](#input\_deletion\_protection\_enabled) | Whether deletion protection is enabled | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name tag for both DSQL clusters | `string` | n/a | yes |
| <a name="input_primary_region"></a> [primary\_region](#input\_primary\_region) | Region for the primary DSQL cluster | `string` | n/a | yes |
| <a name="input_secondary_region"></a> [secondary\_region](#input\_secondary\_region) | Region for the secondary DSQL cluster | `string` | n/a | yes |
| <a name="input_ssm_prefix"></a> [ssm\_prefix](#input\_ssm\_prefix) | Prefix for SSM parameter names (e.g. /transactrx/dsql) | `string` | n/a | yes |
| <a name="input_witness_region"></a> [witness\_region](#input\_witness\_region) | Region to use as the witness in multi-region properties | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_primary_arn"></a> [primary\_arn](#output\_primary\_arn) | n/a |
| <a name="output_primary_identifier"></a> [primary\_identifier](#output\_primary\_identifier) | n/a |
| <a name="output_primary_vpc_endpoint_service_name"></a> [primary\_vpc\_endpoint\_service\_name](#output\_primary\_vpc\_endpoint\_service\_name) | VPC endpoint service name for the primary DSQL cluster |
| <a name="output_secondary_arn"></a> [secondary\_arn](#output\_secondary\_arn) | n/a |
| <a name="output_secondary_identifier"></a> [secondary\_identifier](#output\_secondary\_identifier) | n/a |
| <a name="output_secondary_vpc_endpoint_service_name"></a> [secondary\_vpc\_endpoint\_service\_name](#output\_secondary\_vpc\_endpoint\_service\_name) | VPC endpoint service name for the secondary DSQL cluster |
<!-- END_TF_DOCS -->
