# policies

## Usage

```hcl
module "policies" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/cdspipeline/policies"

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
| [aws_iam_policy.codebuildPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.codepipelinePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_codebuildSecrets"></a> [codebuildSecrets](#input\_codebuildSecrets) | n/a | `list(string)` | n/a | yes |
| <a name="input_codepipelineBucketArn"></a> [codepipelineBucketArn](#input\_codepipelineBucketArn) | n/a | `any` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codebuildPolicyArn"></a> [codebuildPolicyArn](#output\_codebuildPolicyArn) | n/a |
| <a name="output_codebuildPolicyId"></a> [codebuildPolicyId](#output\_codebuildPolicyId) | n/a |
| <a name="output_codepipelinePolicyArn"></a> [codepipelinePolicyArn](#output\_codepipelinePolicyArn) | n/a |
| <a name="output_codepipelinePolicyId"></a> [codepipelinePolicyId](#output\_codepipelinePolicyId) | n/a |
<!-- END_TF_DOCS -->
