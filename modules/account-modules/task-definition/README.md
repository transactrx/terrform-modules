# task-definition

## Usage

```hcl
module "task-definition" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/account-modules/task-definition"

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
| [aws_ecs_task_definition.test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.secretsAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_CPU"></a> [CPU](#input\_CPU) | n/a | `number` | n/a | yes |
| <a name="input_CPU_Arch"></a> [CPU\_Arch](#input\_CPU\_Arch) | n/a | `string` | `"X86_64"` | no |
| <a name="input_ContainerList"></a> [ContainerList](#input\_ContainerList) | n/a | `any` | n/a | yes |
| <a name="input_Memory"></a> [Memory](#input\_Memory) | n/a | `number` | n/a | yes |
| <a name="input_Os"></a> [Os](#input\_Os) | n/a | `string` | `"LINUX"` | no |
| <a name="input_addExtraFargateStorage"></a> [addExtraFargateStorage](#input\_addExtraFargateStorage) | n/a | `bool` | `false` | no |
| <a name="input_additionalTrustedServices"></a> [additionalTrustedServices](#input\_additionalTrustedServices) | n/a | `list(string)` | `[]` | no |
| <a name="input_ecs_execution_role_name"></a> [ecs\_execution\_role\_name](#input\_ecs\_execution\_role\_name) | Override for ECS Task Execution Role name | `string` | `null` | no |
| <a name="input_ecs_task_role_name"></a> [ecs\_task\_role\_name](#input\_ecs\_task\_role\_name) | Override for ECS Task Execution Role name | `string` | `null` | no |
| <a name="input_mainImageURL"></a> [mainImageURL](#input\_mainImageURL) | n/a | `string` | n/a | yes |
| <a name="input_taskDefFamily"></a> [taskDefFamily](#input\_taskDefFamily) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_execution_role_arn"></a> [execution\_role\_arn](#output\_execution\_role\_arn) | n/a |
| <a name="output_execution_role_name"></a> [execution\_role\_name](#output\_execution\_role\_name) | n/a |
| <a name="output_taskDefArn"></a> [taskDefArn](#output\_taskDefArn) | n/a |
| <a name="output_task_definition_full_path"></a> [task\_definition\_full\_path](#output\_task\_definition\_full\_path) | n/a |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | n/a |
| <a name="output_task_role_name"></a> [task\_role\_name](#output\_task\_role\_name) | n/a |
<!-- END_TF_DOCS -->
