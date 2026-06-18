# codebuild

## Usage

```hcl
module "codebuild" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/cdspipeline/codebuild"

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
| [aws_codebuild_project.codebuildProject](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.codebuildProjectArm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.codebuildProjectManifest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_ecr_repository.ecrRepo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_arm64Support"></a> [arm64Support](#input\_arm64Support) | n/a | `bool` | `false` | no |
| <a name="input_buildVariables"></a> [buildVariables](#input\_buildVariables) | n/a | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>    type  = string<br/>  }))</pre> | `[]` | no |
| <a name="input_codebuildRoleArn"></a> [codebuildRoleArn](#input\_codebuildRoleArn) | n/a | `string` | n/a | yes |
| <a name="input_dockerHubCredentials"></a> [dockerHubCredentials](#input\_dockerHubCredentials) | n/a | `any` | n/a | yes |
| <a name="input_gitURL"></a> [gitURL](#input\_gitURL) | n/a | `string` | n/a | yes |
| <a name="input_githubAccessToken"></a> [githubAccessToken](#input\_githubAccessToken) | n/a | `any` | n/a | yes |
| <a name="input_logGroupName"></a> [logGroupName](#input\_logGroupName) | n/a | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_tomcatDownloadLocation"></a> [tomcatDownloadLocation](#input\_tomcatDownloadLocation) | n/a | `any` | n/a | yes |
| <a name="input_useDefaultBuildSpec"></a> [useDefaultBuildSpec](#input\_useDefaultBuildSpec) | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codebuildRepositoryUrl"></a> [codebuildRepositoryUrl](#output\_codebuildRepositoryUrl) | n/a |
<!-- END_TF_DOCS -->
