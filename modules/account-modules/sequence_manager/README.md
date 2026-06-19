# sequence_manager

## Usage

```hcl
module "sequence_manager" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/account-modules/sequence_manager"

  # ... see inputs below
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.seq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_role.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.claim](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function_url.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_url) | resource |
| [aws_ssm_parameter.claimed_priority](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.lambda_pointer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [archive_file.lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.lambda_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_lambda_invocation.claim_next](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lambda_invocation) | data source |
| [aws_ssm_parameter.lambda_pointer_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_mode"></a> [billing\_mode](#input\_billing\_mode) | (provision) DynamoDB billing mode. | `string` | `"PAY_PER_REQUEST"` | no |
| <a name="input_claim_parameter_prefix"></a> [claim\_parameter\_prefix](#input\_claim\_parameter\_prefix) | (claim) SSM prefix where the claimed value is stored. | `string` | `"/ras/services"` | no |
| <a name="input_create_function_url"></a> [create\_function\_url](#input\_create\_function\_url) | (provision) Create Lambda Function URL. | `bool` | `false` | no |
| <a name="input_function_url_auth_type"></a> [function\_url\_auth\_type](#input\_function\_url\_auth\_type) | (provision) Function URL auth type. | `string` | `"AWS_IAM"` | no |
| <a name="input_lambda_name"></a> [lambda\_name](#input\_lambda\_name) | (provision) Lambda function name to create. | `string` | `"ras-claim-next-seq"` | no |
| <a name="input_lambda_pointer_ssm_name"></a> [lambda\_pointer\_ssm\_name](#input\_lambda\_pointer\_ssm\_name) | SSM parameter name that stores the sequence Lambda function name. | `string` | `"/ras/shared/sequence_lambda_name"` | no |
| <a name="input_mode"></a> [mode](#input\_mode) | Use 'provision' to create the shared counter; 'claim' for services to get their number. | `string` | n/a | yes |
| <a name="input_point_in_time_recovery"></a> [point\_in\_time\_recovery](#input\_point\_in\_time\_recovery) | (provision) Enable PITR for the table. | `bool` | `true` | no |
| <a name="input_sequence_name"></a> [sequence\_name](#input\_sequence\_name) | (claim) Logical sequence name (e.g., 'alb-main:443'). One per listener. | `string` | `null` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | (claim) Service identifier, used in persisted parameter path. | `string` | `null` | no |
| <a name="input_step"></a> [step](#input\_step) | (claim) Increment size. 10 -> 10,20,30,... for ALB priorities. | `number` | `10` | no |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | (provision) DynamoDB table name. | `string` | `"ras-sequences"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_claimed_parameter"></a> [claimed\_parameter](#output\_claimed\_parameter) | (claim) SSM parameter storing your claimed priority. |
| <a name="output_function_url"></a> [function\_url](#output\_function\_url) | (provision) Function URL if created (else null). |
| <a name="output_lambda_name"></a> [lambda\_name](#output\_lambda\_name) | (provision) Lambda name (null in claim mode). |
| <a name="output_lambda_pointer_written"></a> [lambda\_pointer\_written](#output\_lambda\_pointer\_written) | (provision) SSM parameter where Lambda name is published. |
| <a name="output_priority"></a> [priority](#output\_priority) | (claim) Your stable ALB listener rule priority (e.g., 10, 20, 30...). Null in provision mode. |
| <a name="output_table_name"></a> [table\_name](#output\_table\_name) | (provision) DynamoDB table name (null in claim mode). |
<!-- END_TF_DOCS -->
