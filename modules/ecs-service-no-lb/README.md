# ecs-service-no-lb

ECS service without a load balancer. Use for background workers, internal services, or tasks that don't need inbound traffic.

## Usage

```hcl
module "worker" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/ecs-service-no-lb"

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
| <a name="module_codePipeline"></a> [codePipeline](#module\_codePipeline) | ../cdspipeline | n/a |
| <a name="module_pwl-tcp-server-testTaskDef"></a> [pwl-tcp-server-testTaskDef](#module\_pwl-tcp-server-testTaskDef) | ../task-definition | n/a |
| <a name="module_pwl-tcp-service"></a> [pwl-tcp-service](#module\_pwl-tcp-service) | ../ecs-service | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.pwl-tcp-server-test-log-group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_codeBuildRoleArn"></a> [codeBuildRoleArn](#input\_codeBuildRoleArn) | n/a | `string` | n/a | yes |
| <a name="input_codePipelineRoleArn"></a> [codePipelineRoleArn](#input\_codePipelineRoleArn) | n/a | `string` | n/a | yes |
| <a name="input_codePipelineS3BucketName"></a> [codePipelineS3BucketName](#input\_codePipelineS3BucketName) | n/a | `string` | n/a | yes |
| <a name="input_containerList"></a> [containerList](#input\_containerList) | n/a | `any` | n/a | yes |
| <a name="input_cpu_units"></a> [cpu\_units](#input\_cpu\_units) | n/a | `number` | `1024` | no |
| <a name="input_deploySubnets"></a> [deploySubnets](#input\_deploySubnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_desiredCount"></a> [desiredCount](#input\_desiredCount) | n/a | `number` | n/a | yes |
| <a name="input_dockerHubCredSecretArn"></a> [dockerHubCredSecretArn](#input\_dockerHubCredSecretArn) | n/a | `string` | n/a | yes |
| <a name="input_ecsClusterName"></a> [ecsClusterName](#input\_ecsClusterName) | n/a | `any` | n/a | yes |
| <a name="input_gitHubTokenSecretManagerArn"></a> [gitHubTokenSecretManagerArn](#input\_gitHubTokenSecretManagerArn) | n/a | `string` | n/a | yes |
| <a name="input_githubBranch"></a> [githubBranch](#input\_githubBranch) | n/a | `string` | n/a | yes |
| <a name="input_githubConnectionArn"></a> [githubConnectionArn](#input\_githubConnectionArn) | n/a | `string` | n/a | yes |
| <a name="input_githubURL"></a> [githubURL](#input\_githubURL) | n/a | `string` | n/a | yes |
| <a name="input_memory_mb"></a> [memory\_mb](#input\_memory\_mb) | n/a | `number` | `512` | no |
| <a name="input_serviceName"></a> [serviceName](#input\_serviceName) | n/a | `any` | n/a | yes |
| <a name="input_vpcId"></a> [vpcId](#input\_vpcId) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
