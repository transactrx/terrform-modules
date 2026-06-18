# ecs

## Usage

```hcl
module "ecs" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/ecs-service_old/ecs"

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
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_alb_target_group.tg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_target_group) | resource |
| [aws_cloudwatch_event_rule.event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.ecs_scheduled_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.logGroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.ecsService](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.nlbEcsService](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_iam_role.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.scheduled_task_cw_event_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.allowExecIntoContainer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.scheduled_task_cw_event_role_cloudwatch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.secretsAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb_listener.NlbListeners](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.nlbTargetGroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.sgNLB](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [null_resource.delete-temporary-file](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.ecs_task_definition](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_cloudformation_export.privateSubnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudformation_export) | data source |
| [aws_cloudformation_export.vpcId](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudformation_export) | data source |
| [aws_ecs_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_ecs_task_definition.taskDef](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_task_definition) | data source |
| [aws_iam_policy_document.scheduled_task_cw_event_role_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scheduled_task_cw_event_role_cloudwatch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.currentRegion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AdditionalSecrets"></a> [AdditionalSecrets](#input\_AdditionalSecrets) | n/a | `map` | `{}` | no |
| <a name="input_NLBArn"></a> [NLBArn](#input\_NLBArn) | n/a | `any` | n/a | yes |
| <a name="input_SSLPolicy"></a> [SSLPolicy](#input\_SSLPolicy) | n/a | `string` | `""` | no |
| <a name="input_additionalCPU"></a> [additionalCPU](#input\_additionalCPU) | n/a | `number` | `0` | no |
| <a name="input_additionalContainers"></a> [additionalContainers](#input\_additionalContainers) | n/a | `list(string)` | `[]` | no |
| <a name="input_additionalEnvVars"></a> [additionalEnvVars](#input\_additionalEnvVars) | n/a | `any` | n/a | yes |
| <a name="input_additionalMemory"></a> [additionalMemory](#input\_additionalMemory) | n/a | `number` | `0` | no |
| <a name="input_albSgId"></a> [albSgId](#input\_albSgId) | n/a | `any` | n/a | yes |
| <a name="input_appName"></a> [appName](#input\_appName) | n/a | `any` | n/a | yes |
| <a name="input_appProxyImageUri"></a> [appProxyImageUri](#input\_appProxyImageUri) | AppProxy Def | `string` | `""` | no |
| <a name="input_awsLogGroup"></a> [awsLogGroup](#input\_awsLogGroup) | n/a | `any` | n/a | yes |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | n/a | `any` | n/a | yes |
| <a name="input_connectToLB"></a> [connectToLB](#input\_connectToLB) | n/a | `bool` | `true` | no |
| <a name="input_dataBase"></a> [dataBase](#input\_dataBase) | n/a | `string` | `"prod"` | no |
| <a name="input_deploymentType"></a> [deploymentType](#input\_deploymentType) | n/a | `string` | `"FARGATE"` | no |
| <a name="input_desiredCount"></a> [desiredCount](#input\_desiredCount) | n/a | `number` | n/a | yes |
| <a name="input_ecsImage"></a> [ecsImage](#input\_ecsImage) | n/a | `any` | n/a | yes |
| <a name="input_envPostFix"></a> [envPostFix](#input\_envPostFix) | n/a | `string` | `""` | no |
| <a name="input_ephemeralStorage"></a> [ephemeralStorage](#input\_ephemeralStorage) | n/a | `number` | `0` | no |
| <a name="input_healthCheckPath"></a> [healthCheckPath](#input\_healthCheckPath) | n/a | `any` | n/a | yes |
| <a name="input_listenerArn"></a> [listenerArn](#input\_listenerArn) | n/a | `any` | n/a | yes |
| <a name="input_listenerHosts"></a> [listenerHosts](#input\_listenerHosts) | n/a | `list(string)` | `[]` | no |
| <a name="input_listenerPath"></a> [listenerPath](#input\_listenerPath) | n/a | `list(string)` | n/a | yes |
| <a name="input_listenerPriority"></a> [listenerPriority](#input\_listenerPriority) | n/a | `number` | n/a | yes |
| <a name="input_mailImageUri"></a> [mailImageUri](#input\_mailImageUri) | mail container definition | `string` | `""` | no |
| <a name="input_memCachedHost"></a> [memCachedHost](#input\_memCachedHost) | main container definition | `string` | `""` | no |
| <a name="input_mountPoints"></a> [mountPoints](#input\_mountPoints) | n/a | `list` | `[]` | no |
| <a name="input_networkLbCertificateArn"></a> [networkLbCertificateArn](#input\_networkLbCertificateArn) | n/a | `any` | `null` | no |
| <a name="input_networkLbProtocol"></a> [networkLbProtocol](#input\_networkLbProtocol) | n/a | `string` | `"TCP"` | no |
| <a name="input_nlb"></a> [nlb](#input\_nlb) | n/a | `bool` | `false` | no |
| <a name="input_nlbHealthCheckPort"></a> [nlbHealthCheckPort](#input\_nlbHealthCheckPort) | n/a | `number` | `0` | no |
| <a name="input_nlbPorts"></a> [nlbPorts](#input\_nlbPorts) | n/a | <pre>list(object({<br/>    servicePort   = number<br/>    protocol      = string<br/>    nlbPort       = number<br/>    containerName = string<br/>  }))</pre> | `[]` | no |
| <a name="input_pgBouncerImageUri"></a> [pgBouncerImageUri](#input\_pgBouncerImageUri) | n/a | `string` | `""` | no |
| <a name="input_pgBouncerNoAuthImageUri"></a> [pgBouncerNoAuthImageUri](#input\_pgBouncerNoAuthImageUri) | pgbouncer | `string` | `""` | no |
| <a name="input_preserveLog"></a> [preserveLog](#input\_preserveLog) | n/a | `bool` | `false` | no |
| <a name="input_privileged"></a> [privileged](#input\_privileged) | n/a | `bool` | `false` | no |
| <a name="input_publicDomain"></a> [publicDomain](#input\_publicDomain) | n/a | `any` | n/a | yes |
| <a name="input_scheduleCron"></a> [scheduleCron](#input\_scheduleCron) | n/a | `string` | `""` | no |
| <a name="input_serviceName"></a> [serviceName](#input\_serviceName) | n/a | `any` | n/a | yes |
| <a name="input_servicePort"></a> [servicePort](#input\_servicePort) | n/a | `string` | `"8080"` | no |
| <a name="input_stunnelImageUri"></a> [stunnelImageUri](#input\_stunnelImageUri) | stunnel | `string` | `""` | no |
| <a name="input_taskCPU"></a> [taskCPU](#input\_taskCPU) | n/a | `number` | `256` | no |
| <a name="input_taskMemoryMb"></a> [taskMemoryMb](#input\_taskMemoryMb) | n/a | `number` | `2048` | no |
| <a name="input_useAppProxy"></a> [useAppProxy](#input\_useAppProxy) | n/a | `bool` | `false` | no |
| <a name="input_useArm"></a> [useArm](#input\_useArm) | n/a | `bool` | `false` | no |
| <a name="input_useMail"></a> [useMail](#input\_useMail) | n/a | `bool` | n/a | yes |
| <a name="input_useMongoConnection"></a> [useMongoConnection](#input\_useMongoConnection) | n/a | `bool` | `false` | no |
| <a name="input_useNoAuthPgBouncer"></a> [useNoAuthPgBouncer](#input\_useNoAuthPgBouncer) | n/a | `bool` | `false` | no |
| <a name="input_usePgBouncer"></a> [usePgBouncer](#input\_usePgBouncer) | n/a | `bool` | n/a | yes |
| <a name="input_useStunnel"></a> [useStunnel](#input\_useStunnel) | n/a | `bool` | n/a | yes |
| <a name="input_useWaf"></a> [useWaf](#input\_useWaf) | n/a | `bool` | `false` | no |
| <a name="input_volumeFrom"></a> [volumeFrom](#input\_volumeFrom) | n/a | `list` | `[]` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | n/a | `list` | `[]` | no |
| <a name="input_wafImageUri"></a> [wafImageUri](#input\_wafImageUri) | waf taskdef | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_taskExecutionRoleArn"></a> [taskExecutionRoleArn](#output\_taskExecutionRoleArn) | n/a |
| <a name="output_taskExecutionRoleName"></a> [taskExecutionRoleName](#output\_taskExecutionRoleName) | n/a |
| <a name="output_taskRoleArn"></a> [taskRoleArn](#output\_taskRoleArn) | n/a |
| <a name="output_taskRoleName"></a> [taskRoleName](#output\_taskRoleName) | n/a |
<!-- END_TF_DOCS -->
