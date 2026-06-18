# ecs-service-with-nlb

## Usage

```hcl
module "ecs-service-with-nlb" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/account-modules/ecs-service-with-nlb"

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
| [aws_appautoscaling_policy.ecs_average_cpu_scaling_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.ecs_memory_scaling_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.ecs_service_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_ecs_service.pwl-tcp-server-test-ecs-service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_lb_listener.nlbListeners](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.nlbTargetGroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.serviceSg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.sgRules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_lb.lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_scaler_config"></a> [auto\_scaler\_config](#input\_auto\_scaler\_config) | n/a | <pre>object({<br/>    max_capacity = optional(number, 10)<br/>    min_capacity = optional(number, 1)<br/><br/>    enable_cpu_scaling         = optional(bool, false)<br/>    cpu_scale_out_target_value = optional(number, 80)<br/>    cpu_scale_in_target_value  = optional(number, 60)<br/>    cpu_scale_in_cooldown      = optional(number, 120)<br/>    cpu_scale_out_cooldown     = optional(number, 120)<br/><br/>    enable_memory_scaling      = optional(bool, false)<br/>    mem_scale_out_target_value = optional(number, 80)<br/>    mem_scale_in_target_value  = optional(number, 60)<br/>    mem_scale_in_cooldown      = optional(number, 120)<br/>    mem_scale_out_cooldown     = optional(number, 120)<br/>  })</pre> | <pre>{<br/>  "cpu_scale_in_cooldown": 120,<br/>  "cpu_scale_in_target_value": 60,<br/>  "cpu_scale_out_cooldown": 120,<br/>  "cpu_scale_out_target_value": 80,<br/>  "enable_cpu_scaling": false,<br/>  "enable_memory_scaling": false,<br/>  "max_capacity": 10,<br/>  "mem_scale_in_cooldown": 120,<br/>  "mem_scale_in_target_value": 60,<br/>  "mem_scale_out_cooldown": 120,<br/>  "mem_scale_out_target_value": 80,<br/>  "min_capacity": 1<br/>}</pre> | no |
| <a name="input_clusterName"></a> [clusterName](#input\_clusterName) | n/a | `string` | n/a | yes |
| <a name="input_deploymentMaxPercent"></a> [deploymentMaxPercent](#input\_deploymentMaxPercent) | n/a | `number` | `200` | no |
| <a name="input_desiredCount"></a> [desiredCount](#input\_desiredCount) | n/a | `number` | n/a | yes |
| <a name="input_ecs_service_protocol"></a> [ecs\_service\_protocol](#input\_ecs\_service\_protocol) | n/a | `string` | `"TLS"` | no |
| <a name="input_enableExecuteCommand"></a> [enableExecuteCommand](#input\_enableExecuteCommand) | n/a | `bool` | `false` | no |
| <a name="input_networkLoadBalancerAttachments"></a> [networkLoadBalancerAttachments](#input\_networkLoadBalancerAttachments) | n/a | <pre>list(<br/>    object({<br/>      containerName      = string<br/>      containerPort      = number<br/>      protocol           = string<br/>      lbArn              = string<br/>      lbPort             = number<br/>      certificateArn     = optional(string)<br/>      ssl_policy         = optional(string)<br/>      name               = optional(string)<br/>      healthCheckPort    = optional(number)<br/>      alpn_policy        = optional(string)<br/>      preserve_client_ip = optional(bool)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "alpn_policy": null,<br/>    "certificateArn": null,<br/>    "containerName": null,<br/>    "containerPort": null,<br/>    "healthCheckPort": null,<br/>    "lbArn": null,<br/>    "lbPort": null,<br/>    "name": null,<br/>    "preserve_client_ip": null,<br/>    "protocol": null,<br/>    "ssl_policy": null<br/>  }<br/>]</pre> | no |
| <a name="input_nlb_tls_policy"></a> [nlb\_tls\_policy](#input\_nlb\_tls\_policy) | Default SSL/TLS security policy for NLB TLS listeners. | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |
| <a name="input_serviceName"></a> [serviceName](#input\_serviceName) | ECS Service Name | `string` | n/a | yes |
| <a name="input_subNets"></a> [subNets](#input\_subNets) | n/a | `list(string)` | n/a | yes |
| <a name="input_taskDefinitionFull"></a> [taskDefinitionFull](#input\_taskDefinitionFull) | n/a | `any` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_securityGroupArn"></a> [securityGroupArn](#output\_securityGroupArn) | n/a |
| <a name="output_securityGroupId"></a> [securityGroupId](#output\_securityGroupId) | n/a |
| <a name="output_securityGroupName"></a> [securityGroupName](#output\_securityGroupName) | n/a |
<!-- END_TF_DOCS -->
