# dsql-service-endpoints

DSQL VPC endpoints for private connectivity.

## Usage

```hcl
module "endpoints" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/dsql-service-endpoints"

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
| [aws_security_group.dsql_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_parameter.arn_param](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.dns_param](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_vpc_endpoint.dsql_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_security_group_ingress_rule.dsql_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dsql_clusters"></a> [dsql\_clusters](#input\_dsql\_clusters) | List of DSQL clusters with network and service details | <pre>list(object({<br/>    dsql_arn          = string<br/>    dsql_id           = string<br/>    dsql_service_name = string<br/>    vpc_id            = string<br/>    subnet_ids        = list(string)<br/>    region            = string<br/>    name              = string<br/>    vpc_cidr          = string<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_dns_domains"></a> [private\_dns\_domains](#output\_private\_dns\_domains) | Private DNS domains for each DSQL cluster |
<!-- END_TF_DOCS -->
