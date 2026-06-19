<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs"></a> [ecs](#module\_ecs) | ./ecs | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_NLBArn"></a> [NLBArn](#input\_NLBArn) | n/a | `string` | `""` | no |
| <a name="input_addEcsToCodeDeploy"></a> [addEcsToCodeDeploy](#input\_addEcsToCodeDeploy) | n/a | `bool` | `true` | no |
| <a name="input_additionSecrets"></a> [additionSecrets](#input\_additionSecrets) | n/a | `map` | `{}` | no |
| <a name="input_additionalCPU"></a> [additionalCPU](#input\_additionalCPU) | n/a | `number` | `0` | no |
| <a name="input_additionalContainers"></a> [additionalContainers](#input\_additionalContainers) | n/a | `list` | `[]` | no |
| <a name="input_additionalEnvVars"></a> [additionalEnvVars](#input\_additionalEnvVars) | n/a | `map` | `{}` | no |
| <a name="input_additionalMemory"></a> [additionalMemory](#input\_additionalMemory) | n/a | `number` | `0` | no |
| <a name="input_albSgId"></a> [albSgId](#input\_albSgId) | n/a | `string` | `""` | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | n/a | `any` | n/a | yes |
| <a name="input_connectToLB"></a> [connectToLB](#input\_connectToLB) | n/a | `bool` | n/a | yes |
| <a name="input_deploymentType"></a> [deploymentType](#input\_deploymentType) | n/a | `string` | `"FARGATE"` | no |
| <a name="input_desiredCount"></a> [desiredCount](#input\_desiredCount) | n/a | `number` | n/a | yes |
| <a name="input_dockerHubCredSecretArn"></a> [dockerHubCredSecretArn](#input\_dockerHubCredSecretArn) | n/a | `any` | n/a | yes |
| <a name="input_ecsMainImageUri"></a> [ecsMainImageUri](#input\_ecsMainImageUri) | n/a | `any` | n/a | yes |
| <a name="input_envPostFix"></a> [envPostFix](#input\_envPostFix) | n/a | `string` | `""` | no |
| <a name="input_ephemeralStorage"></a> [ephemeralStorage](#input\_ephemeralStorage) | n/a | `number` | `0` | no |
| <a name="input_healthCheckPath"></a> [healthCheckPath](#input\_healthCheckPath) | n/a | `string` | `""` | no |
| <a name="input_lbListenerArn"></a> [lbListenerArn](#input\_lbListenerArn) | n/a | `string` | `""` | no |
| <a name="input_listenerHosts"></a> [listenerHosts](#input\_listenerHosts) | n/a | `list(string)` | `[]` | no |
| <a name="input_listenerPath"></a> [listenerPath](#input\_listenerPath) | n/a | `list(string)` | `[]` | no |
| <a name="input_listenerPriority"></a> [listenerPriority](#input\_listenerPriority) | n/a | `number` | `0` | no |
| <a name="input_mountPoints"></a> [mountPoints](#input\_mountPoints) | n/a | <pre>list(object({<br/>    containerPath = string<br/>    readOnly      = bool<br/>    sourceVolume  = string<br/>  }))</pre> | `[]` | no |
| <a name="input_networkLbCertificateArn"></a> [networkLbCertificateArn](#input\_networkLbCertificateArn) | n/a | `any` | `null` | no |
| <a name="input_networkLbProtocol"></a> [networkLbProtocol](#input\_networkLbProtocol) | n/a | `string` | `"TCP"` | no |
| <a name="input_nlb"></a> [nlb](#input\_nlb) | n/a | `bool` | `false` | no |
| <a name="input_nlbHealthCheckPort"></a> [nlbHealthCheckPort](#input\_nlbHealthCheckPort) | n/a | `number` | `0` | no |
| <a name="input_nlbPorts"></a> [nlbPorts](#input\_nlbPorts) | n/a | <pre>list(object({<br/>    servicePort   = number<br/>    protocol      = string<br/>    nlbPort       = number<br/>    containerName = string<br/>  }))</pre> | `[]` | no |
| <a name="input_preserveLog"></a> [preserveLog](#input\_preserveLog) | n/a | `bool` | `false` | no |
| <a name="input_privileged"></a> [privileged](#input\_privileged) | n/a | `bool` | `false` | no |
| <a name="input_publicDomain"></a> [publicDomain](#input\_publicDomain) | n/a | `string` | `""` | no |
| <a name="input_scheduleCron"></a> [scheduleCron](#input\_scheduleCron) | n/a | `string` | `""` | no |
| <a name="input_serviceName"></a> [serviceName](#input\_serviceName) | n/a | `any` | n/a | yes |
| <a name="input_servicePort"></a> [servicePort](#input\_servicePort) | n/a | `string` | `"8080"` | no |
| <a name="input_taskCPU"></a> [taskCPU](#input\_taskCPU) | n/a | `number` | `256` | no |
| <a name="input_taskMemoryMb"></a> [taskMemoryMb](#input\_taskMemoryMb) | n/a | `number` | `2048` | no |
| <a name="input_useAppProxy"></a> [useAppProxy](#input\_useAppProxy) | n/a | `bool` | `false` | no |
| <a name="input_useArm"></a> [useArm](#input\_useArm) | n/a | `bool` | `false` | no |
| <a name="input_useMail"></a> [useMail](#input\_useMail) | n/a | `bool` | `true` | no |
| <a name="input_useMongoConnection"></a> [useMongoConnection](#input\_useMongoConnection) | n/a | `bool` | `false` | no |
| <a name="input_useNoAuthPgBouncer"></a> [useNoAuthPgBouncer](#input\_useNoAuthPgBouncer) | n/a | `bool` | `false` | no |
| <a name="input_usePgBouncer"></a> [usePgBouncer](#input\_usePgBouncer) | n/a | `bool` | `true` | no |
| <a name="input_useStunnel"></a> [useStunnel](#input\_useStunnel) | n/a | `bool` | `true` | no |
| <a name="input_useWaf"></a> [useWaf](#input\_useWaf) | n/a | `bool` | `true` | no |
| <a name="input_volumeFrom"></a> [volumeFrom](#input\_volumeFrom) | n/a | `list` | `[]` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | n/a | `list` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_taskExecutionRoleArn"></a> [taskExecutionRoleArn](#output\_taskExecutionRoleArn) | n/a |
| <a name="output_taskExecutionRoleName"></a> [taskExecutionRoleName](#output\_taskExecutionRoleName) | n/a |
| <a name="output_taskRoleArn"></a> [taskRoleArn](#output\_taskRoleArn) | n/a |
| <a name="output_taskRoleName"></a> [taskRoleName](#output\_taskRoleName) | n/a |
<!-- END_TF_DOCS -->