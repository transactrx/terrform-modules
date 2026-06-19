# ecs-service-with-alb-v2

ECS service with ALB target group and flexible DNS/routing options. Use this module when you need control over whether DNS records and listener rules are created - for example, when routing through CloudFront or managing DNS externally.

## When to Use

| Scenario | Settings |
|----------|----------|
| Standard ALB routing with DNS | `create_listener_rule = true`, `create_dns_records = true` (defaults) |
| CloudFront in front, DNS points to CloudFront | `create_listener_rule = false`, `create_dns_records = true`, provide `dns_target` |
| External DNS management | `create_dns_records = false` |
| Target group only (routing managed elsewhere) | `create_listener_rule = false`, `create_dns_records = false` |

## Usage Examples

### Standard Usage (same as ecs-service-with-alb)

```hcl
module "api_service" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/ecs-service-with-alb-v2"

  serviceName        = "my-api"
  clusterName        = "prod-cluster"
  vpc_id             = var.vpc_id
  subNets            = var.private_subnet_ids
  desiredCount       = 2
  taskDefinitionFull = aws_ecs_task_definition.api.arn

  hostnames = ["api.example.com"]

  applicationLoadBalancerAttachment = {
    containerName   = "api"
    containerPort   = 8080
    protocol        = "HTTP"
    lbArn           = var.alb_arn
    listenerArn     = var.https_listener_arn
    healthCheckPath = "/health"
    rulePriority    = 100
  }

  tags = {
    Environment = "production"
    Service     = "api"
  }
}
```

### CloudFront Origin (no listener rule, DNS points to CloudFront)

```hcl
module "api_service" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/ecs-service-with-alb-v2"

  serviceName        = "my-api"
  clusterName        = "prod-cluster"
  vpc_id             = var.vpc_id
  subNets            = var.private_subnet_ids
  desiredCount       = 2
  taskDefinitionFull = aws_ecs_task_definition.api.arn

  hostnames            = ["api.example.com"]
  create_listener_rule = false

  # DNS records point to CloudFront instead of ALB
  dns_target = {
    dns_name = aws_cloudfront_distribution.api.domain_name
    zone_id  = "Z2FDTNDATAQYW2"  # CloudFront's hosted zone ID
  }

  applicationLoadBalancerAttachment = {
    containerName   = "api"
    containerPort   = 8080
    protocol        = "HTTP"
    healthCheckPath = "/health"
  }
}

# Use the target_group_arn output to wire up CloudFront -> ALB -> this service
```

### Target Group Only (external routing)

```hcl
module "api_service" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/ecs-service-with-alb-v2"

  serviceName        = "my-api"
  clusterName        = "prod-cluster"
  vpc_id             = var.vpc_id
  subNets            = var.private_subnet_ids
  desiredCount       = 2
  taskDefinitionFull = aws_ecs_task_definition.api.arn

  create_listener_rule = false
  create_dns_records   = false

  applicationLoadBalancerAttachment = {
    containerName   = "api"
    containerPort   = 8080
    protocol        = "HTTP"
    healthCheckPath = "/health"
  }
}

# Use module.api_service.target_group_arn in your own listener rules
```

## Migration from ecs-service-with-alb

This module is a superset of `ecs-service-with-alb`. To migrate:

1. Change source to `ecs-service-with-alb-v2`
2. Replace `dnsName` with `hostnames = ["your-dns-name"]`
3. Replace `additionalDnsNames` by adding to the `hostnames` list
4. Remove `publicHostName` from `applicationLoadBalancerAttachment` (now derived from `hostnames`)

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
| [aws_route53_record.hostname_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.serviceSg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.additional_ingress_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.additional_ingress_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.sgRules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_lb.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_route53_zone.hostname_zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_ingress_rules"></a> [additional\_ingress\_rules](#input\_additional\_ingress\_rules) | Additional ingress rules for the service security group | <pre>list(object({<br/>    from_port        = number<br/>    to_port          = number<br/>    protocol         = string<br/>    cidr_blocks      = optional(list(string))<br/>    security_groups  = optional(list(string))<br/>    description      = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_alb_service_protocol"></a> [alb\_service\_protocol](#input\_alb\_service\_protocol) | Protocol for the ALB target group and health check | `string` | `"HTTP"` | no |
| <a name="input_applicationLoadBalancerAttachment"></a> [applicationLoadBalancerAttachment](#input\_applicationLoadBalancerAttachment) | Configuration for connecting the ECS service to an Application Load Balancer.<br/><br/>Required fields:<br/>- containerName: Name of the container (from task definition) that receives traffic<br/>- containerPort: Port on the container that receives traffic<br/>- protocol: Protocol for the target group (HTTP or HTTPS)<br/><br/>Conditionally required:<br/>- lbArn: ALB ARN. Required when dns\_hostnames is non-empty and dns\_target is not set<br/>- listenerArn: ALB listener ARN. Required when create\_listener\_rule=true<br/><br/>Optional fields:<br/>- name: Override for target group name suffix (default: containerName-containerPort)<br/>- healthCheckPath: Path for health checks (default: "/", can also use health\_check\_config)<br/>- rulePriority: Priority for the listener rule (lower = higher priority)<br/>- pathPattern: URL path pattern for routing (default: "/*") | <pre>object({<br/>    containerName   = string<br/>    containerPort   = number<br/>    protocol        = string<br/>    lbArn           = optional(string)<br/>    listenerArn     = optional(string)<br/>    lbPort          = optional(number)<br/>    certificateArn  = optional(string)<br/>    name            = optional(string)<br/>    healthCheckPath = optional(string)<br/>    rulePriority    = optional(number)<br/>    pathPattern     = optional(string)<br/>  })</pre> | <pre>{<br/>  "certificateArn": null,<br/>  "containerName": null,<br/>  "containerPort": null,<br/>  "healthCheckPath": null,<br/>  "lbArn": null,<br/>  "lbPort": null,<br/>  "listenerArn": null,<br/>  "name": null,<br/>  "pathPattern": null,<br/>  "protocol": null,<br/>  "rulePriority": null<br/>}</pre> | no |
| <a name="input_auto_scaler_config"></a> [auto\_scaler\_config](#input\_auto\_scaler\_config) | Auto-scaling configuration for the ECS service. Scaling is disabled by default.<br/><br/>- max\_capacity/min\_capacity: Task count bounds for scaling<br/>- enable\_cpu\_scaling: Enable CPU-based auto-scaling<br/>- enable\_memory\_scaling: Enable memory-based auto-scaling<br/>- *\_target\_value: Target utilization percentage to trigger scaling<br/>- *\_cooldown: Seconds to wait between scaling actions | <pre>object({<br/>    max_capacity               = optional(number, 10)<br/>    min_capacity               = optional(number, 1)<br/>    enable_cpu_scaling         = optional(bool, false)<br/>    cpu_scale_out_target_value = optional(number, 80)<br/>    cpu_scale_in_target_value  = optional(number, 60)<br/>    cpu_scale_in_cooldown      = optional(number, 120)<br/>    cpu_scale_out_cooldown     = optional(number, 120)<br/>    enable_memory_scaling      = optional(bool, false)<br/>    mem_scale_out_target_value = optional(number, 80)<br/>    mem_scale_in_target_value  = optional(number, 60)<br/>    mem_scale_in_cooldown      = optional(number, 120)<br/>    mem_scale_out_cooldown     = optional(number, 120)<br/>  })</pre> | <pre>{<br/>  "cpu_scale_in_cooldown": 120,<br/>  "cpu_scale_in_target_value": 60,<br/>  "cpu_scale_out_cooldown": 120,<br/>  "cpu_scale_out_target_value": 80,<br/>  "enable_cpu_scaling": false,<br/>  "enable_memory_scaling": false,<br/>  "max_capacity": 10,<br/>  "mem_scale_in_cooldown": 120,<br/>  "mem_scale_in_target_value": 60,<br/>  "mem_scale_out_cooldown": 120,<br/>  "mem_scale_out_target_value": 80,<br/>  "min_capacity": 1<br/>}</pre> | no |
| <a name="input_clusterName"></a> [clusterName](#input\_clusterName) | Name of the ECS cluster where the service will be deployed. | `string` | n/a | yes |
| <a name="input_create_listener_rule"></a> [create\_listener\_rule](#input\_create\_listener\_rule) | Whether to create ALB listener rule for host-header routing. Set to false if listener rules are managed elsewhere (e.g., via CloudFront). | `bool` | `true` | no |
| <a name="input_deploymentMaxPercent"></a> [deploymentMaxPercent](#input\_deploymentMaxPercent) | Upper limit (as a percentage of desiredCount) on the number of running tasks during a deployment. 200 means double capacity during deploys. | `number` | `200` | no |
| <a name="input_deploymentMinPercent"></a> [deploymentMinPercent](#input\_deploymentMinPercent) | Lower limit (as a percentage of desiredCount) on the number of running tasks during a deployment. 100 means no capacity reduction during deploys. | `number` | `100` | no |
| <a name="input_deployment_circuit_breaker"></a> [deployment\_circuit\_breaker](#input\_deployment\_circuit\_breaker) | Deployment circuit breaker configuration. When enabled, ECS stops deploying if tasks fail to stabilize. | <pre>object({<br/>    enable   = optional(bool, false)<br/>    rollback = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | Time (seconds) to wait before deregistering a target. Lower values speed up deployments but may drop in-flight requests. | `number` | `120` | no |
| <a name="input_desiredCount"></a> [desiredCount](#input\_desiredCount) | Number of ECS tasks to run. Auto-scaling may override this value. | `number` | n/a | yes |
| <a name="input_dns_hostnames"></a> [dns\_hostnames](#input\_dns\_hostnames) | Hostnames to create Route53 A records for. Separate from 'hostnames' which is used<br/>for listener rule host-header matching. Use this when you need DNS records for a<br/>subset of hostnames (e.g., only the internal ALB hostname, while CloudFront manages others).<br/>Leave empty to skip DNS record creation entirely. | `list(string)` | `[]` | no |
| <a name="input_dns_target"></a> [dns\_target](#input\_dns\_target) | Optional override for DNS record alias target. When provided, Route53 records point here<br/>instead of the ALB. Useful when traffic flows through CloudFront or another proxy.<br/>Example: { dns\_name = "d1234.cloudfront.net", zone\_id = "Z2FDTNDATAQYW2" } | <pre>object({<br/>    dns_name = string<br/>    zone_id  = string<br/>  })</pre> | `null` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | Enable ECS Exec for debugging (aws ecs execute-command) | `bool` | `false` | no |
| <a name="input_health_check_config"></a> [health\_check\_config](#input\_health\_check\_config) | Target group health check configuration. Path defaults to applicationLoadBalancerAttachment.healthCheckPath or "/". | <pre>object({<br/>    path                = optional(string)<br/>    healthy_threshold   = optional(number, 5)<br/>    unhealthy_threshold = optional(number, 5)<br/>    interval            = optional(number, 30)<br/>    timeout             = optional(number, 5)<br/>    matcher             = optional(string, "200-399")<br/>  })</pre> | `{}` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Seconds to ignore failing load balancer health checks on newly instantiated tasks. Important for slow-starting containers. | `number` | `null` | no |
| <a name="input_hostnames"></a> [hostnames](#input\_hostnames) | Hostnames for ALB listener rule host-header matching (when create\_listener\_rule is true).<br/>For Route53 DNS records, use the separate 'dns\_hostnames' variable.<br/>Example: ["api.example.com", "api.legacy.com"] | `list(string)` | `[]` | no |
| <a name="input_propagate_tags"></a> [propagate\_tags](#input\_propagate\_tags) | Whether to propagate tags from SERVICE or TASK\_DEFINITION to tasks | `string` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Additional security group IDs to attach to the ECS service (in addition to the one created by this module) | `list(string)` | `[]` | no |
| <a name="input_serviceName"></a> [serviceName](#input\_serviceName) | Name of the ECS service. Also used for naming the security group and target group. | `string` | n/a | yes |
| <a name="input_slow_start"></a> [slow\_start](#input\_slow\_start) | Time (seconds) for targets to warm up before receiving full share of requests. 0 disables slow start. | `number` | `0` | no |
| <a name="input_stickiness"></a> [stickiness](#input\_stickiness) | Target group stickiness configuration for session affinity | <pre>object({<br/>    enabled         = optional(bool, false)<br/>    type            = optional(string, "lb_cookie")<br/>    cookie_duration = optional(number, 86400)<br/>    cookie_name     = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_subNets"></a> [subNets](#input\_subNets) | List of subnet IDs where ECS tasks will be launched. Should be private subnets for most workloads. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources created by this module | `map(string)` | `{}` | no |
| <a name="input_taskDefinitionFull"></a> [taskDefinitionFull](#input\_taskDefinitionFull) | Full ARN of the ECS task definition (family:revision or full ARN). | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the ECS service and security group will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_service_id"></a> [ecs\_service\_id](#output\_ecs\_service\_id) | ARN of the ECS service |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | Name of the ECS service |
| <a name="output_securityGroupArn"></a> [securityGroupArn](#output\_securityGroupArn) | ARN of the security group created for this ECS service |
| <a name="output_securityGroupId"></a> [securityGroupId](#output\_securityGroupId) | ID of the security group created for this ECS service |
| <a name="output_securityGroupName"></a> [securityGroupName](#output\_securityGroupName) | Name of the security group created for this ECS service |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | ARN of the target group for use in external listener rules or CloudFront origin |
| <a name="output_target_group_name"></a> [target\_group\_name](#output\_target\_group\_name) | Name of the target group |
<!-- END_TF_DOCS -->
