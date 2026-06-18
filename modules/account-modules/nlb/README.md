# nlb

## Usage

```hcl
module "nlb" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/account-modules/nlb"

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
| [aws_alb.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_elb_service_account.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_private"></a> [private](#input\_private) | n/a | `bool` | n/a | yes |
| <a name="input_securityGroupIds"></a> [securityGroupIds](#input\_securityGroupIds) | Optional list of security group IDs to attach to the NLB. Empty list means no SG attached (legacy behavior). | `list(string)` | `[]` | no |
| <a name="input_subnetIds"></a> [subnetIds](#input\_subnetIds) | n/a | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nlb_arn"></a> [nlb\_arn](#output\_nlb\_arn) | n/a |
| <a name="output_nlb_dns_name"></a> [nlb\_dns\_name](#output\_nlb\_dns\_name) | n/a |
| <a name="output_nlb_name"></a> [nlb\_name](#output\_nlb\_name) | n/a |
| <a name="output_securityGroupId"></a> [securityGroupId](#output\_securityGroupId) | n/a |
<!-- END_TF_DOCS -->
