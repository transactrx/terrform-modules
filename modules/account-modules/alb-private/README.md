# alb-private

## Usage

```hcl
module "alb-private" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/account-modules/alb-private"

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
| [aws_alb_listener.defaultListener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |
| [aws_lb.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener_certificate.additionalCerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_lb_listener_rule.redirectToEnrollment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_listener_rule.redirectToOldUrl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_route53_record.privateHostRecord](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.ALBSecurityGroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs_bucket"></a> [access\_logs\_bucket](#input\_access\_logs\_bucket) | S3 bucket for ALB access logs. Empty disables access logging. | `string` | `""` | no |
| <a name="input_access_logs_prefix"></a> [access\_logs\_prefix](#input\_access\_logs\_prefix) | S3 key prefix for ALB access logs. | `string` | `""` | no |
| <a name="input_additionalCerts"></a> [additionalCerts](#input\_additionalCerts) | n/a | `list(string)` | `[]` | no |
| <a name="input_albName"></a> [albName](#input\_albName) | n/a | `string` | n/a | yes |
| <a name="input_corpDomain"></a> [corpDomain](#input\_corpDomain) | n/a | `string` | n/a | yes |
| <a name="input_manage_dns"></a> [manage\_dns](#input\_manage\_dns) | n/a | `bool` | `true` | no |
| <a name="input_privateSubnets"></a> [privateSubnets](#input\_privateSubnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_privateZoneId"></a> [privateZoneId](#input\_privateZoneId) | n/a | `any` | n/a | yes |
| <a name="input_publicCertificate"></a> [publicCertificate](#input\_publicCertificate) | n/a | `string` | n/a | yes |
| <a name="input_publicDomain"></a> [publicDomain](#input\_publicDomain) | n/a | `string` | n/a | yes |
| <a name="input_publicDomainNaked"></a> [publicDomainNaked](#input\_publicDomainNaked) | n/a | `string` | n/a | yes |
| <a name="input_vpcId"></a> [vpcId](#input\_vpcId) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_defaultListenerArn"></a> [defaultListenerArn](#output\_defaultListenerArn) | n/a |
| <a name="output_dns"></a> [dns](#output\_dns) | n/a |
| <a name="output_loadBalancerArn"></a> [loadBalancerArn](#output\_loadBalancerArn) | n/a |
| <a name="output_privateSubnets"></a> [privateSubnets](#output\_privateSubnets) | n/a |
| <a name="output_securityGroupId"></a> [securityGroupId](#output\_securityGroupId) | n/a |
<!-- END_TF_DOCS -->
