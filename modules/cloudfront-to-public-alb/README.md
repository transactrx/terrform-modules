# cloudfront-to-public-alb

CloudFront distribution with a public ALB origin.

## Usage

```hcl
module "cdn" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/cloudfront-to-public-alb"

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
| [aws_cloudfront_cache_policy.forward_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_distribution.proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_request_policy.all_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |
| [aws_route53_record.cf_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.cf_alias_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | n/a | `string` | n/a | yes |
| <a name="input_additional_dns_names"></a> [additional\_dns\_names](#input\_additional\_dns\_names) | Optional: additional fully-qualified domain names to serve from this distribution, in addition to public\_dns\_name. Defaults to an empty list so existing callers are unaffected. NOTE: the certificate referenced by acm\_certificate\_arn must include every name listed here as a Subject Alternative Name (SAN), otherwise CloudFront will reject the alias. | `list(string)` | `[]` | no |
| <a name="input_desitination_domain"></a> [desitination\_domain](#input\_desitination\_domain) | n/a | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_public_dns_name"></a> [public\_dns\_name](#input\_public\_dns\_name) | n/a | `string` | n/a | yes |
| <a name="input_waf_protection_id"></a> [waf\_protection\_id](#input\_waf\_protection\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | n/a |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | n/a |
<!-- END_TF_DOCS -->
