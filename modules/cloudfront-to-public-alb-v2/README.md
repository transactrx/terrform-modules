# cloudfront-to-public-alb-v2

## Usage

```hcl
module "cloudfront-to-public-alb-v2" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/cloudfront-to-public-alb-v2"

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
| [aws_route53_record.dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.dns_zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | ARN of the ACM certificate for CloudFront to use. | `string` | n/a | yes |
| <a name="input_cache_default_ttl"></a> [cache\_default\_ttl](#input\_cache\_default\_ttl) | Default TTL for cached objects in seconds. | `number` | `3` | no |
| <a name="input_cache_max_ttl"></a> [cache\_max\_ttl](#input\_cache\_max\_ttl) | Maximum TTL for cached objects in seconds. | `number` | `3` | no |
| <a name="input_cache_min_ttl"></a> [cache\_min\_ttl](#input\_cache\_min\_ttl) | Minimum TTL for cached objects in seconds. | `number` | `3` | no |
| <a name="input_cloudfront_aliases"></a> [cloudfront\_aliases](#input\_cloudfront\_aliases) | All domain names (aliases) this CloudFront distribution serves.<br/>These are added to the CloudFront distribution's Aliases list.<br/>Example: ["www.example.com", "example.com"] | `list(string)` | n/a | yes |
| <a name="input_destination_domain"></a> [destination\_domain](#input\_destination\_domain) | Origin domain name (e.g., the ALB internal hostname). | `string` | n/a | yes |
| <a name="input_dns_hostnames"></a> [dns\_hostnames](#input\_dns\_hostnames) | Hostnames to create Route53 A records for, pointing to this CloudFront distribution.<br/>Separate from cloudfront\_aliases to allow managing DNS independently.<br/>Leave empty to skip DNS record creation entirely. | `list(string)` | `[]` | no |
| <a name="input_geo_restriction_locations"></a> [geo\_restriction\_locations](#input\_geo\_restriction\_locations) | List of country codes for geo restriction whitelist. | `list(string)` | <pre>[<br/>  "US"<br/>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the CloudFront distribution and associated resources. | `string` | n/a | yes |
| <a name="input_origin_protocol_policy"></a> [origin\_protocol\_policy](#input\_origin\_protocol\_policy) | Protocol policy for origin requests: http-only, https-only, or match-viewer. | `string` | `"match-viewer"` | no |
| <a name="input_origin_ssl_protocols"></a> [origin\_ssl\_protocols](#input\_origin\_ssl\_protocols) | SSL/TLS protocols for origin connections. | `list(string)` | <pre>[<br/>  "TLSv1.2"<br/>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_waf_protection_id"></a> [waf\_protection\_id](#input\_waf\_protection\_id) | ARN of the WAF WebACL to associate with the distribution. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_distribution_arn"></a> [distribution\_arn](#output\_distribution\_arn) | CloudFront distribution ARN. |
| <a name="output_distribution_id"></a> [distribution\_id](#output\_distribution\_id) | CloudFront distribution ID. |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | CloudFront distribution domain name. |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | CloudFront distribution hosted zone ID. |
<!-- END_TF_DOCS -->
