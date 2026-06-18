# alb

Application Load Balancer module.

## Usage

```hcl
module "alb" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/alb"

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_private"></a> [private](#input\_private) | n/a | `bool` | n/a | yes |
| <a name="input_subnetIds"></a> [subnetIds](#input\_subnetIds) | n/a | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nlb_arn"></a> [nlb\_arn](#output\_nlb\_arn) | n/a |
| <a name="output_nlb_dns_name"></a> [nlb\_dns\_name](#output\_nlb\_dns\_name) | n/a |
| <a name="output_nlb_name"></a> [nlb\_name](#output\_nlb\_name) | n/a |
<!-- END_TF_DOCS -->
