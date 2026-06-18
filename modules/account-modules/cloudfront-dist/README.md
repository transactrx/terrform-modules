# cloudfront-dist

## Usage

```hcl
module "cloudfront-dist" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/account-modules/cloudfront-dist"

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
| <a name="input_GEO_ALLOWED_COUNTRIES"></a> [GEO\_ALLOWED\_COUNTRIES](#input\_GEO\_ALLOWED\_COUNTRIES) | n/a | `list(string)` | <pre>[<br/>  "US"<br/>]</pre> | no |
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | n/a | `string` | n/a | yes |
| <a name="input_additional_aliases"></a> [additional\_aliases](#input\_additional\_aliases) | Extra alternate domain names (CNAMEs) to serve from this distribution, in addition to public\_dns\_name. The ACM certificate must cover all of them. | `list(string)` | `[]` | no |
| <a name="input_cache_policy_id"></a> [cache\_policy\_id](#input\_cache\_policy\_id) | n/a | `string` | n/a | yes |
| <a name="input_desitination_domain"></a> [desitination\_domain](#input\_desitination\_domain) | n/a | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_origin_keepalive_timeout"></a> [origin\_keepalive\_timeout](#input\_origin\_keepalive\_timeout) | n/a | `number` | `5` | no |
| <a name="input_origin_read_timeout"></a> [origin\_read\_timeout](#input\_origin\_read\_timeout) | n/a | `number` | `30` | no |
| <a name="input_origin_request_policy_id"></a> [origin\_request\_policy\_id](#input\_origin\_request\_policy\_id) | n/a | `string` | n/a | yes |
| <a name="input_origin_verify_secret"></a> [origin\_verify\_secret](#input\_origin\_verify\_secret) | When non-empty, adds an X-Origin-Verify custom header to the origin with this value. | `string` | `""` | no |
| <a name="input_public_dns_name"></a> [public\_dns\_name](#input\_public\_dns\_name) | n/a | `string` | n/a | yes |
| <a name="input_waf_protection_arn"></a> [waf\_protection\_arn](#input\_waf\_protection\_arn) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | n/a |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | n/a |
<!-- END_TF_DOCS -->
