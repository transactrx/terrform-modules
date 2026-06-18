# ecs-service-with-alb

## Usage

```hcl
module "ecs-service-with-alb" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/account-modules/ecs-service-with-alb"

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
| [aws_ecs_service.ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_lb_listener_rule.albListenerRule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.albTargetGroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.app_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.serviceSg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.sgRules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_lb.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_service_protocol"></a> [alb\_service\_protocol](#input\_alb\_service\_protocol) | Protocol for the ALB target group and health check | `string` | `"HTTP"` | no |
| <a name="input_applicationLoadBalancerAttachment"></a> [applicationLoadBalancerAttachment](#input\_applicationLoadBalancerAttachment) | n/a | <pre>object({<br/>    containerName       = string<br/>    containerPort       = number<br/>    protocol            = string<br/>    lbArn               = string<br/>    listenerArn         = string<br/>    lbPort              = number<br/>    certificateArn      = optional(string)<br/>    name                = optional(string)<br/>    healthCheckPath     = optional(string)<br/>    rulePriority        = optional(number)<br/>    pathPattern         = optional(string)<br/>    publicHostName      = string<br/>    healthy_threshold   = optional(number)<br/>    unhealthy_threshold = optional(number)<br/>    matcher             = optional(string)<br/>    interval            = optional(number)<br/>    timeout             = optional(number)<br/>    stickiness = optional(object({<br/>      enabled         = optional(bool, false)<br/>      type            = optional(string, "lb_cookie")<br/>      cookie_duration = optional(number, 86400)<br/>    }))<br/>  })</pre> | <pre>{<br/>  "certificateArn": null,<br/>  "containerName": null,<br/>  "containerPort": null,<br/>  "healthCheckPath": null,<br/>  "healthy_threshold": null,<br/>  "interval": null,<br/>  "lbArn": null,<br/>  "lbPort": null,<br/>  "listenerArn": null,<br/>  "matcher": null,<br/>  "name": null,<br/>  "pathPattern": null,<br/>  "protocol": null,<br/>  "publicHostName": null,<br/>  "rulePriority": null,<br/>  "stickiness": null,<br/>  "timeout": null,<br/>  "unhealthy_threshold": null<br/>}</pre> | no |
| <a name="input_auto_scaler_config"></a> [auto\_scaler\_config](#input\_auto\_scaler\_config) | n/a | <pre>object({<br/>    max_capacity               = optional(number, 10)<br/>    min_capacity               = optional(number, 1)<br/>    enable_cpu_scaling         = optional(bool, false)<br/>    cpu_scale_out_target_value = optional(number, 80)<br/>    cpu_scale_in_target_value  = optional(number, 60)<br/>    cpu_scale_in_cooldown      = optional(number, 120)<br/>    cpu_scale_out_cooldown     = optional(number, 120)<br/>    enable_memory_scaling      = optional(bool, false)<br/>    mem_scale_out_target_value = optional(number, 80)<br/>    mem_scale_in_target_value  = optional(number, 60)<br/>    mem_scale_in_cooldown      = optional(number, 120)<br/>    mem_scale_out_cooldown     = optional(number, 120)<br/>  })</pre> | <pre>{<br/>  "cpu_scale_in_cooldown": 120,<br/>  "cpu_scale_in_target_value": 60,<br/>  "cpu_scale_out_cooldown": 120,<br/>  "cpu_scale_out_target_value": 80,<br/>  "enable_cpu_scaling": false,<br/>  "enable_memory_scaling": false,<br/>  "max_capacity": 10,<br/>  "mem_scale_in_cooldown": 120,<br/>  "mem_scale_in_target_value": 60,<br/>  "mem_scale_out_cooldown": 120,<br/>  "mem_scale_out_target_value": 80,<br/>  "min_capacity": 1<br/>}</pre> | no |
| <a name="input_clusterName"></a> [clusterName](#input\_clusterName) | n/a | `string` | n/a | yes |
| <a name="input_create_route53_record"></a> [create\_route53\_record](#input\_create\_route53\_record) | Whether to create a Route53 DNS record | `bool` | `true` | no |
| <a name="input_deploymentMaxPercent"></a> [deploymentMaxPercent](#input\_deploymentMaxPercent) | n/a | `number` | `200` | no |
| <a name="input_desiredCount"></a> [desiredCount](#input\_desiredCount) | n/a | `number` | n/a | yes |
| <a name="input_dnsName"></a> [dnsName](#input\_dnsName) | FQDN for DNS record (optional if Route53 record creation disabled) | `string` | `null` | no |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | Seconds to wait before ECS acts on ALB health check failures (useful for slow-starting apps) | `number` | `200` | no |
| <a name="input_serviceName"></a> [serviceName](#input\_serviceName) | ECS Service Name | `string` | n/a | yes |
| <a name="input_subNets"></a> [subNets](#input\_subNets) | n/a | `list(string)` | n/a | yes |
| <a name="input_taskDefinitionFull"></a> [taskDefinitionFull](#input\_taskDefinitionFull) | n/a | `any` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_securityGroupArn"></a> [securityGroupArn](#output\_securityGroupArn) | n/a |
| <a name="output_securityGroupId"></a> [securityGroupId](#output\_securityGroupId) | n/a |
| <a name="output_securityGroupName"></a> [securityGroupName](#output\_securityGroupName) | n/a |
| <a name="output_targetGroupName"></a> [targetGroupName](#output\_targetGroupName) | n/a |
<!-- END_TF_DOCS -->
