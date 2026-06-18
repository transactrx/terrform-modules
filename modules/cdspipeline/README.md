# cdspipeline

AWS CodePipeline modules for CI/CD infrastructure.

## Modules

| Module | Description |
|--------|-------------|
| [codebuild](./codebuild) | CodeBuild project configuration |
| [codepipeline](./codepipeline) | CodePipeline configuration |
| [policies](./policies) | IAM policies for CI/CD |
| [roles](./roles) | IAM roles for CI/CD |

## Usage

```hcl
module "pipeline" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/cdspipeline"

  # ... module inputs
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
| <a name="module_codebuild"></a> [codebuild](#module\_codebuild) | ./codebuild | n/a |
| <a name="module_codepipeline"></a> [codepipeline](#module\_codepipeline) | ./codepipeline | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_secretsmanager_secret.dockerhubCreds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret.gitHubAccessToken](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addEcsToCodeDeploy"></a> [addEcsToCodeDeploy](#input\_addEcsToCodeDeploy) | n/a | `bool` | `false` | no |
| <a name="input_arm64Support"></a> [arm64Support](#input\_arm64Support) | n/a | `bool` | `false` | no |
| <a name="input_branchName"></a> [branchName](#input\_branchName) | n/a | `any` | n/a | yes |
| <a name="input_buildVariables"></a> [buildVariables](#input\_buildVariables) | n/a | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>    type  = string<br/>  }))</pre> | `[]` | no |
| <a name="input_clusterName"></a> [clusterName](#input\_clusterName) | n/a | `any` | n/a | yes |
| <a name="input_codeBuildLogGroupName"></a> [codeBuildLogGroupName](#input\_codeBuildLogGroupName) | n/a | `any` | n/a | yes |
| <a name="input_codeBuildRoleArn"></a> [codeBuildRoleArn](#input\_codeBuildRoleArn) | n/a | `any` | n/a | yes |
| <a name="input_codePipelineRoleArn"></a> [codePipelineRoleArn](#input\_codePipelineRoleArn) | n/a | `any` | n/a | yes |
| <a name="input_codePipelineS3BucketName"></a> [codePipelineS3BucketName](#input\_codePipelineS3BucketName) | n/a | `any` | n/a | yes |
| <a name="input_dockerHubCredSecretArn"></a> [dockerHubCredSecretArn](#input\_dockerHubCredSecretArn) | n/a | `any` | n/a | yes |
| <a name="input_gitHubTokenSecretManagerArn"></a> [gitHubTokenSecretManagerArn](#input\_gitHubTokenSecretManagerArn) | n/a | `any` | n/a | yes |
| <a name="input_gitHubURL"></a> [gitHubURL](#input\_gitHubURL) | n/a | `any` | n/a | yes |
| <a name="input_githubConnectionArn"></a> [githubConnectionArn](#input\_githubConnectionArn) | n/a | `any` | n/a | yes |
| <a name="input_serviceName"></a> [serviceName](#input\_serviceName) | n/a | `any` | n/a | yes |
| <a name="input_tomcatDownloadLocation"></a> [tomcatDownloadLocation](#input\_tomcatDownloadLocation) | n/a | `string` | `""` | no |
| <a name="input_useDefaultBuildSpec"></a> [useDefaultBuildSpec](#input\_useDefaultBuildSpec) | n/a | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_imageUrl"></a> [imageUrl](#output\_imageUrl) | n/a |
| <a name="output_serviceName"></a> [serviceName](#output\_serviceName) | n/a |
<!-- END_TF_DOCS -->
