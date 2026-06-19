# codepipeline

## Usage

```hcl
module "codepipeline" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/cdspipeline/codepipeline"

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
| [aws_codepipeline.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_arm64Support"></a> [arm64Support](#input\_arm64Support) | n/a | `bool` | `false` | no |
| <a name="input_branchName"></a> [branchName](#input\_branchName) | n/a | `any` | n/a | yes |
| <a name="input_bucketName"></a> [bucketName](#input\_bucketName) | n/a | `any` | n/a | yes |
| <a name="input_deployEcs"></a> [deployEcs](#input\_deployEcs) | n/a | `bool` | `false` | no |
| <a name="input_ecsClusterName"></a> [ecsClusterName](#input\_ecsClusterName) | n/a | `string` | `"nocluster"` | no |
| <a name="input_ecsServiceName"></a> [ecsServiceName](#input\_ecsServiceName) | n/a | `string` | `"noservice"` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `any` | n/a | yes |
| <a name="input_repositoryFullName"></a> [repositoryFullName](#input\_repositoryFullName) | n/a | `any` | n/a | yes |
| <a name="input_roleArn"></a> [roleArn](#input\_roleArn) | n/a | `any` | n/a | yes |
| <a name="input_sourceCodeConnectionArn"></a> [sourceCodeConnectionArn](#input\_sourceCodeConnectionArn) | n/a | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
