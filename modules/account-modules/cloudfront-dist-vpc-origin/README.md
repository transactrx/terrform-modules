# cloudfront-dist-vpc-origin

## Usage

```hcl
module "cloudfront-dist-vpc-origin" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/account-modules/cloudfront-dist-vpc-origin"

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
| [aws_cloudfront_distribution.proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | n/a | `string` | n/a | yes |
| <a name="input_cache_policy_id"></a> [cache\_policy\_id](#input\_cache\_policy\_id) | n/a | `string` | n/a | yes |
| <a name="input_destination_domain"></a> [destination\_domain](#input\_destination\_domain) | n/a | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_origin_request_policy_id"></a> [origin\_request\_policy\_id](#input\_origin\_request\_policy\_id) | n/a | `string` | n/a | yes |
| <a name="input_public_dns_name"></a> [public\_dns\_name](#input\_public\_dns\_name) | n/a | `string` | n/a | yes |
| <a name="input_vpc_origin_id"></a> [vpc\_origin\_id](#input\_vpc\_origin\_id) | ID of the aws\_cloudfront\_vpc\_origin created separately | `string` | n/a | yes |
| <a name="input_waf_protection_arn"></a> [waf\_protection\_arn](#input\_waf\_protection\_arn) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | Keep outputs the same |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | n/a |
<!-- END_TF_DOCS -->
