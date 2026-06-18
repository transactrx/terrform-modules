# ecs-service-with-alb

ECS service with ALB listener rules and Route53 DNS records. Creates a complete routing stack for web services.

## Usage

```hcl
module "api_service" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/ecs-service-with-alb"

  serviceName        = "my-api"
  clusterName        = "prod-cluster"
  vpc_id             = var.vpc_id
  subNets            = var.private_subnet_ids
  desiredCount       = 2
  taskDefinitionFull = aws_ecs_task_definition.api.arn
  dnsName            = "api.example.com"

  applicationLoadBalancerAttachment = {
    containerName   = "api"
    containerPort   = 8080
    protocol        = "HTTP"
    lbArn           = var.alb_arn
    listenerArn     = var.https_listener_arn
    publicHostName  = "api.example.com"
    healthCheckPath = "/health"
    rulePriority    = 100
  }
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
| [aws_route53_record.additional_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.app_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.serviceSg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.sgRules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_lb.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_route53_zone.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additionalDnsNames"></a> [additionalDnsNames](#input\_additionalDnsNames) | Optional additional FQDNs that should map to this service (e.g. ["domain2.com", "domain3.com"]).<br/>Each name is added to the listener rule's host-header match (OR semantics with dnsName) and gets<br/>its own public Route53 A (alias) record. Each name may live in a different public hosted zone.<br/>Leave empty for the original single-domain behavior. | `list(string)` | `[]` | no |
| <a name="input_alb_service_protocol"></a> [alb\_service\_protocol](#input\_alb\_service\_protocol) | Protocol for the ALB target group and health check | `string` | `"HTTP"` | no |
| <a name="input_applicationLoadBalancerAttachment"></a> [applicationLoadBalancerAttachment](#input\_applicationLoadBalancerAttachment) | n/a | <pre>object({<br/>    containerName   = string<br/>    containerPort   = number<br/>    protocol        = string<br/>    lbArn           = string<br/>    listenerArn     = string<br/>    lbPort          = number<br/>    certificateArn  = optional(string)<br/>    name            = optional(string)<br/>    healthCheckPath = optional(string)<br/>    rulePriority    = optional(number)<br/>    pathPattern     = optional(string)<br/>    publicHostName  = string<br/>  })</pre> | <pre>{<br/>  "certificateArn": null,<br/>  "containerName": null,<br/>  "containerPort": null,<br/>  "healthCheckPath": null,<br/>  "lbArn": null,<br/>  "lbPort": null,<br/>  "listenerArn": null,<br/>  "name": null,<br/>  "pathPattern": null,<br/>  "protocol": null,<br/>  "publicHostName": null,<br/>  "rulePriority": null<br/>}</pre> | no |
| <a name="input_auto_scaler_config"></a> [auto\_scaler\_config](#input\_auto\_scaler\_config) | n/a | <pre>object({<br/>    max_capacity               = optional(number, 10)<br/>    min_capacity               = optional(number, 1)<br/>    enable_cpu_scaling         = optional(bool, false)<br/>    cpu_scale_out_target_value = optional(number, 80)<br/>    cpu_scale_in_target_value  = optional(number, 60)<br/>    cpu_scale_in_cooldown      = optional(number, 120)<br/>    cpu_scale_out_cooldown     = optional(number, 120)<br/>    enable_memory_scaling      = optional(bool, false)<br/>    mem_scale_out_target_value = optional(number, 80)<br/>    mem_scale_in_target_value  = optional(number, 60)<br/>    mem_scale_in_cooldown      = optional(number, 120)<br/>    mem_scale_out_cooldown     = optional(number, 120)<br/>  })</pre> | <pre>{<br/>  "cpu_scale_in_cooldown": 120,<br/>  "cpu_scale_in_target_value": 60,<br/>  "cpu_scale_out_cooldown": 120,<br/>  "cpu_scale_out_target_value": 80,<br/>  "enable_cpu_scaling": false,<br/>  "enable_memory_scaling": false,<br/>  "max_capacity": 10,<br/>  "mem_scale_in_cooldown": 120,<br/>  "mem_scale_in_target_value": 60,<br/>  "mem_scale_out_cooldown": 120,<br/>  "mem_scale_out_target_value": 80,<br/>  "min_capacity": 1<br/>}</pre> | no |
| <a name="input_clusterName"></a> [clusterName](#input\_clusterName) | n/a | `string` | n/a | yes |
| <a name="input_deploymentMaxPercent"></a> [deploymentMaxPercent](#input\_deploymentMaxPercent) | n/a | `number` | `200` | no |
| <a name="input_desiredCount"></a> [desiredCount](#input\_desiredCount) | n/a | `number` | n/a | yes |
| <a name="input_dnsName"></a> [dnsName](#input\_dnsName) | n/a | `string` | n/a | yes |
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
<!-- END_TF_DOCS -->
