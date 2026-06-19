# codePiplineDependencies

CodePipeline supporting resources (S3 buckets, IAM roles, etc.).

## Usage

```hcl
module "pipeline_deps" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/codePiplineDependencies"

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_codebuildRole"></a> [codebuildRole](#module\_codebuildRole) | ../cdspipeline/roles | n/a |
| <a name="module_codepipelineRole"></a> [codepipelineRole](#module\_codepipelineRole) | ../cdspipeline/roles | n/a |
| <a name="module_policies"></a> [policies](#module\_policies) | ../cdspipeline/policies | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.codepipeline_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dockerHubCredSecretArn"></a> [dockerHubCredSecretArn](#input\_dockerHubCredSecretArn) | n/a | `string` | n/a | yes |
| <a name="input_gitHubTokenSecretArn"></a> [gitHubTokenSecretArn](#input\_gitHubTokenSecretArn) | n/a | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codeBuildRoleArn"></a> [codeBuildRoleArn](#output\_codeBuildRoleArn) | n/a |
| <a name="output_codeBuildRoleName"></a> [codeBuildRoleName](#output\_codeBuildRoleName) | n/a |
| <a name="output_codePipeLineS3Arn"></a> [codePipeLineS3Arn](#output\_codePipeLineS3Arn) | n/a |
| <a name="output_codePipelineRoleArn"></a> [codePipelineRoleArn](#output\_codePipelineRoleArn) | n/a |
| <a name="output_codePipelineRoleName"></a> [codePipelineRoleName](#output\_codePipelineRoleName) | n/a |
| <a name="output_codePipelineS3Bucket"></a> [codePipelineS3Bucket](#output\_codePipelineS3Bucket) | n/a |
<!-- END_TF_DOCS -->
