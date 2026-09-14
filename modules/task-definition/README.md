# task-definition

Task definition builder module.

## Usage

```hcl
module "task_def" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/task-definition"

  # ... see inputs below
}
```

## Existing task roles and upgrades

`existing_task_role_arn` defaults to `null`. Omit it to retain the existing role names,
execution role, ECS Exec policy and outputs. Terraform 1.1 or newer applies the permanent
`moved` blocks without replacing the managed role or policy.

Supply an IAM role ARN to use a role owned by another state. The module does not read,
create or manage that role or any of its policies. Its owner must configure ECS task
trust, application permissions and ECS Exec. Execution-role behavior is unchanged.
`task_role_name` returns the final role name even when the ARN contains an IAM path.

**Switching an existing deployment:** changing to an external ARN would normally destroy
the module-managed task role and ECS Exec policy. First transfer them to explicit retained
resources with `moved` blocks, or back up state and remove those two addresses from state
if they are intentionally unmanaged. Review a plan with no IAM deletions before applying.
Do not remove rollback roles while active or rollback task definitions need them. Switching
back requires moving/importing the retained resources into the module again.

The mocked compatibility suite is in `tests/task-definition`; it applies the exact legacy
module, plans an unchanged consumer upgrade in the same state, and exercises external roles.

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
| [aws_iam_role_policy.ecs_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
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
| <a name="input_ecs_execution_role_name"></a> [ecs\_execution\_role\_name](#input\_ecs\_execution\_role\_name) | Override for ECS Task Execution Role name | `string` | `null` | no |
| <a name="input_ecs_task_role_name"></a> [ecs\_task\_role\_name](#input\_ecs\_task\_role\_name) | Override for ECS Task Execution Role name | `string` | `null` | no |
| <a name="input_efsVolumes"></a> [efsVolumes](#input\_efsVolumes) | EFS volumes to attach to the task. Containers reference them by name via mountPoints. Transit encryption is always on; when accessPointId is set, IAM authorization is enabled (grant the task role elasticfilesystem:ClientMount/ClientWrite on the filesystem). | <pre>list(object({<br/>    name          = string<br/>    fileSystemId  = string<br/>    accessPointId = optional(string)<br/>  }))</pre> | `[]` | no |
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
