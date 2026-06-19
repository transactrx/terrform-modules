###########################
# Variables
###########################

variable "serviceName" {
  type        = string
  description = "Name of the ECS service. Also used for naming the security group and target group."
}

variable "clusterName" {
  type        = string
  description = "Name of the ECS cluster where the service will be deployed."
}

variable "deploymentMaxPercent" {
  type        = number
  description = "Upper limit (as a percentage of desiredCount) on the number of running tasks during a deployment. 200 means double capacity during deploys."
  default     = 200
}

variable "deploymentMinPercent" {
  type        = number
  description = "Lower limit (as a percentage of desiredCount) on the number of running tasks during a deployment. 100 means no capacity reduction during deploys."
  default     = 100
}

variable "subNets" {
  type        = list(string)
  description = "List of subnet IDs where ECS tasks will be launched. Should be private subnets for most workloads."
}

variable "taskDefinitionFull" {
  type        = string
  description = "Full ARN of the ECS task definition (family:revision or full ARN)."
}

variable "desiredCount" {
  type        = number
  description = "Number of ECS tasks to run. Auto-scaling may override this value."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the ECS service and security group will be created."
}

variable "hostnames" {
  type        = list(string)
  description = <<-EOT
    Hostnames for ALB listener rule host-header matching (when create_listener_rule is true).
    For Route53 DNS records, use the separate 'dns_hostnames' variable.
    Example: ["api.example.com", "api.legacy.com"]
  EOT
  default     = []
}

variable "create_listener_rule" {
  type        = bool
  description = "Whether to create ALB listener rule for host-header routing. Set to false if listener rules are managed elsewhere (e.g., via CloudFront)."
  default     = true
}

variable "dns_hostnames" {
  type        = list(string)
  description = <<-EOT
    Hostnames to create Route53 A records for. Separate from 'hostnames' which is used
    for listener rule host-header matching. Use this when you need DNS records for a
    subset of hostnames (e.g., only the internal ALB hostname, while CloudFront manages others).
    Leave empty to skip DNS record creation entirely.
  EOT
  default     = []
}

# Validation moved to locals to provide clear error messages at plan time

variable "dns_target" {
  type = object({
    dns_name = string
    zone_id  = string
  })
  description = <<-EOT
    Optional override for DNS record alias target. When provided, Route53 records point here
    instead of the ALB. Useful when traffic flows through CloudFront or another proxy.
    Example: { dns_name = "d1234.cloudfront.net", zone_id = "Z2FDTNDATAQYW2" }
  EOT
  default     = null
}

variable "applicationLoadBalancerAttachment" {
  description = <<-EOT
    Configuration for connecting the ECS service to an Application Load Balancer.

    Required fields:
    - containerName: Name of the container (from task definition) that receives traffic
    - containerPort: Port on the container that receives traffic
    - protocol: Protocol for the target group (HTTP or HTTPS)

    Conditionally required:
    - lbArn: ALB ARN. Required when dns_hostnames is non-empty and dns_target is not set
    - listenerArn: ALB listener ARN. Required when create_listener_rule=true

    Optional fields:
    - name: Override for target group name suffix (default: containerName-containerPort)
    - healthCheckPath: Path for health checks (default: "/", can also use health_check_config)
    - rulePriority: Priority for the listener rule (lower = higher priority)
    - pathPattern: URL path pattern for routing (default: "/*")
  EOT

  type = object({
    containerName   = string
    containerPort   = number
    protocol        = string
    lbArn           = optional(string)
    listenerArn     = optional(string)
    lbPort          = optional(number)
    certificateArn  = optional(string)
    name            = optional(string)
    healthCheckPath = optional(string)
    rulePriority    = optional(number)
    pathPattern     = optional(string)
  })

  default = {
    containerName   = null,
    containerPort   = null,
    protocol        = null,
    lbArn           = null,
    lbPort          = null,
    certificateArn  = null,
    name            = null,
    healthCheckPath = null,
    rulePriority    = null,
    pathPattern     = null,
    listenerArn     = null
  }
}

variable "alb_service_protocol" {
  description = "Protocol for the ALB target group and health check"
  type        = string
  default     = "HTTP"
}

variable "health_check_config" {
  type = object({
    path                = optional(string)
    healthy_threshold   = optional(number, 5)
    unhealthy_threshold = optional(number, 5)
    interval            = optional(number, 30)
    timeout             = optional(number, 5)
    matcher             = optional(string, "200-399")
  })
  description = <<-EOT
    Target group health check configuration. Path defaults to applicationLoadBalancerAttachment.healthCheckPath or "/".
  EOT
  default     = {}
}

variable "deregistration_delay" {
  type        = number
  description = "Time (seconds) to wait before deregistering a target. Lower values speed up deployments but may drop in-flight requests."
  default     = 120
}

variable "slow_start" {
  type        = number
  description = "Time (seconds) for targets to warm up before receiving full share of requests. 0 disables slow start."
  default     = 0
}

variable "stickiness" {
  type = object({
    enabled         = optional(bool, false)
    type            = optional(string, "lb_cookie")
    cookie_duration = optional(number, 86400)
    cookie_name     = optional(string)
  })
  description = "Target group stickiness configuration for session affinity"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources created by this module"
  default     = {}
}

variable "enable_execute_command" {
  type        = bool
  description = "Enable ECS Exec for debugging (aws ecs execute-command)"
  default     = false
}

variable "health_check_grace_period" {
  type        = number
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks. Important for slow-starting containers."
  default     = null
}

variable "deployment_circuit_breaker" {
  type = object({
    enable   = optional(bool, false)
    rollback = optional(bool, false)
  })
  description = "Deployment circuit breaker configuration. When enabled, ECS stops deploying if tasks fail to stabilize."
  default     = {}
}

variable "propagate_tags" {
  type        = string
  description = "Whether to propagate tags from SERVICE or TASK_DEFINITION to tasks"
  default     = null
  validation {
    condition     = var.propagate_tags == null || contains(["SERVICE", "TASK_DEFINITION"], var.propagate_tags)
    error_message = "propagate_tags must be null, SERVICE, or TASK_DEFINITION"
  }
}

variable "security_group_ids" {
  type        = list(string)
  description = "Additional security group IDs to attach to the ECS service (in addition to the one created by this module)"
  default     = []
}

variable "additional_ingress_rules" {
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string))
    security_groups  = optional(list(string))
    description      = optional(string)
  }))
  description = "Additional ingress rules for the service security group"
  default     = []
}

variable "auto_scaler_config" {
  description = <<-EOT
    Auto-scaling configuration for the ECS service. Scaling is disabled by default.

    - max_capacity/min_capacity: Task count bounds for scaling
    - enable_cpu_scaling: Enable CPU-based auto-scaling
    - enable_memory_scaling: Enable memory-based auto-scaling
    - *_target_value: Target utilization percentage to trigger scaling
    - *_cooldown: Seconds to wait between scaling actions
  EOT

  type = object({
    max_capacity               = optional(number, 10)
    min_capacity               = optional(number, 1)
    enable_cpu_scaling         = optional(bool, false)
    cpu_scale_out_target_value = optional(number, 80)
    cpu_scale_in_target_value  = optional(number, 60)
    cpu_scale_in_cooldown      = optional(number, 120)
    cpu_scale_out_cooldown     = optional(number, 120)
    enable_memory_scaling      = optional(bool, false)
    mem_scale_out_target_value = optional(number, 80)
    mem_scale_in_target_value  = optional(number, 60)
    mem_scale_in_cooldown      = optional(number, 120)
    mem_scale_out_cooldown     = optional(number, 120)
  })
  default = {
    max_capacity               = 10
    min_capacity               = 1
    enable_cpu_scaling         = false
    cpu_scale_out_target_value = 80
    cpu_scale_in_target_value  = 60
    cpu_scale_in_cooldown      = 120
    cpu_scale_out_cooldown     = 120
    enable_memory_scaling      = false
    mem_scale_out_target_value = 80
    mem_scale_in_target_value  = 60
    mem_scale_in_cooldown      = 120
    mem_scale_out_cooldown     = 120
  }
}

###########################
# Locals
###########################

locals {
  # Determine if we need to look up the ALB (for DNS records when no override provided)
  lookup_alb = length(var.dns_hostnames) > 0 && var.dns_target == null

  # Per-hostname zone name (last two labels of each FQDN) for DNS records
  dns_hostname_zone_names = {
    for h in var.dns_hostnames :
    h => join(".", slice(split(".", h), length(split(".", h)) - 2, length(split(".", h))))
  }

  # DNS alias target - either explicit override or looked-up ALB
  dns_alias_target = var.dns_target != null ? var.dns_target : (
    local.lookup_alb ? {
      dns_name = data.aws_lb.alb[0].dns_name
      zone_id  = data.aws_lb.alb[0].zone_id
    } : null
  )

  containerPortToBeOpen = var.applicationLoadBalancerAttachment.containerPort

  # Merge health check config with defaults
  health_check_path = coalesce(
    var.health_check_config.path,
    var.applicationLoadBalancerAttachment.healthCheckPath,
    "/"
  )

  # All security groups for the ECS service
  all_security_groups = concat([aws_security_group.serviceSg.id], var.security_group_ids)

  # Target group name (max 32 chars for AWS)
  target_group_name_raw = (var.applicationLoadBalancerAttachment.name != null ?
    "${var.serviceName}-${var.applicationLoadBalancerAttachment.name}" :
    "${var.serviceName}-${var.applicationLoadBalancerAttachment.containerName}-${var.applicationLoadBalancerAttachment.containerPort}"
  )
  target_group_name = substr(local.target_group_name_raw, 0, 32)

  # Validation checks
  validate_listener_arn = (
    var.create_listener_rule && var.applicationLoadBalancerAttachment.listenerArn == null
    ? tobool("ERROR: listenerArn is required in applicationLoadBalancerAttachment when create_listener_rule is true")
    : true
  )

  validate_lb_arn = (
    local.lookup_alb && var.applicationLoadBalancerAttachment.lbArn == null
    ? tobool("ERROR: lbArn is required in applicationLoadBalancerAttachment when dns_hostnames is non-empty and dns_target is not provided")
    : true
  )
}

###########################
# Data Sources
###########################

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_lb" "alb" {
  count = local.lookup_alb ? 1 : 0
  arn   = var.applicationLoadBalancerAttachment.lbArn
}

# Hosted zone lookup for each dns_hostname
data "aws_route53_zone" "hostname_zones" {
  for_each     = length(var.dns_hostnames) > 0 ? toset(var.dns_hostnames) : toset([])
  name         = local.dns_hostname_zone_names[each.value]
  private_zone = false
}

###########################
# Route53 DNS Records
###########################

resource "aws_route53_record" "hostname_dns" {
  for_each = local.dns_alias_target != null ? toset(var.dns_hostnames) : toset([])
  zone_id  = data.aws_route53_zone.hostname_zones[each.value].zone_id
  name     = each.value
  type     = "A"

  alias {
    name                   = local.dns_alias_target.dns_name
    zone_id                = local.dns_alias_target.zone_id
    evaluate_target_health = false
  }
}

###########################
# Security Group and Rules
###########################

resource "aws_security_group" "serviceSg" {
  name   = var.serviceName
  vpc_id = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, {
    Name = var.serviceName
  })
}

resource "aws_security_group_rule" "sgRules" {
  from_port         = local.containerPortToBeOpen
  protocol          = "TCP"
  security_group_id = aws_security_group.serviceSg.id
  to_port           = local.containerPortToBeOpen
  type              = "ingress"
  cidr_blocks       = [data.aws_vpc.vpc.cidr_block]
  description       = "Allow traffic from within VPC"
}

resource "aws_security_group_rule" "additional_ingress_cidr" {
  for_each = {
    for idx, rule in var.additional_ingress_rules : idx => rule
    if length(coalesce(rule.cidr_blocks, [])) > 0
  }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.serviceSg.id
  cidr_blocks       = each.value.cidr_blocks
  description       = each.value.description
}

resource "aws_security_group_rule" "additional_ingress_sg" {
  for_each = {
    for item in flatten([
      for idx, rule in var.additional_ingress_rules : [
        for sg in coalesce(rule.security_groups, []) : {
          key         = "${idx}-${sg}"
          from_port   = rule.from_port
          to_port     = rule.to_port
          protocol    = rule.protocol
          sg_id       = sg
          description = rule.description
        }
      ]
    ]) : item.key => item
  }

  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  security_group_id        = aws_security_group.serviceSg.id
  source_security_group_id = each.value.sg_id
  description              = each.value.description
}

###########################
# ALB Target Groups
###########################

resource "aws_lb_target_group" "albTargetGroup" {
  protocol             = var.alb_service_protocol
  target_type          = "ip"
  name                 = local.target_group_name
  deregistration_delay = var.deregistration_delay
  slow_start           = var.slow_start
  port                 = var.applicationLoadBalancerAttachment.containerPort
  vpc_id               = var.vpc_id

  health_check {
    protocol            = var.alb_service_protocol
    path                = local.health_check_path
    healthy_threshold   = var.health_check_config.healthy_threshold
    unhealthy_threshold = var.health_check_config.unhealthy_threshold
    matcher             = var.health_check_config.matcher
    interval            = var.health_check_config.interval
    timeout             = var.health_check_config.timeout
  }

  dynamic "stickiness" {
    for_each = var.stickiness.enabled ? [1] : []
    content {
      enabled         = true
      type            = var.stickiness.type
      cookie_duration = var.stickiness.cookie_duration
      cookie_name     = var.stickiness.type == "app_cookie" ? var.stickiness.cookie_name : null
    }
  }

  tags = var.tags
}

###########################
# ALB Listeners and Rules
###########################

resource "aws_lb_listener_rule" "albListenerRule" {
  count        = var.create_listener_rule ? 1 : 0
  listener_arn = var.applicationLoadBalancerAttachment.listenerArn

  priority = var.applicationLoadBalancerAttachment.rulePriority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.albTargetGroup.arn
  }

  condition {
    path_pattern {
      values = [
        var.applicationLoadBalancerAttachment.pathPattern != null ?
        var.applicationLoadBalancerAttachment.pathPattern : "/*"
      ]
    }
  }

  dynamic "condition" {
    for_each = length(var.hostnames) > 0 ? [1] : []
    content {
      host_header {
        values = var.hostnames
      }
    }
  }

  tags = var.tags
}

###########################
# ECS Service
###########################

resource "aws_ecs_service" "ecs_service" {
  name                       = var.serviceName
  cluster                    = var.clusterName
  deployment_maximum_percent = var.deploymentMaxPercent
  deployment_minimum_healthy_percent = var.deploymentMinPercent
  desired_count              = var.desiredCount
  task_definition            = var.taskDefinitionFull
  enable_execute_command     = var.enable_execute_command
  health_check_grace_period_seconds = var.health_check_grace_period
  propagate_tags             = var.propagate_tags

  load_balancer {
    container_name   = var.applicationLoadBalancerAttachment.containerName
    container_port   = var.applicationLoadBalancerAttachment.containerPort
    target_group_arn = aws_lb_target_group.albTargetGroup.arn
  }

  network_configuration {
    subnets         = var.subNets
    security_groups = local.all_security_groups
  }

  dynamic "deployment_circuit_breaker" {
    for_each = var.deployment_circuit_breaker.enable ? [1] : []
    content {
      enable   = true
      rollback = var.deployment_circuit_breaker.rollback
    }
  }

  lifecycle {
    ignore_changes = [
      "capacity_provider_strategy"
    ]
  }

  tags = var.tags
}

###########################
# Auto Scaling Resources
###########################

resource "aws_appautoscaling_target" "ecs_service_target" {
  count = var.auto_scaler_config.enable_cpu_scaling || var.auto_scaler_config.enable_memory_scaling ? 1 : 0

  max_capacity       = var.auto_scaler_config.max_capacity
  min_capacity       = var.auto_scaler_config.min_capacity
  resource_id        = "service/${var.clusterName}/${var.serviceName}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_average_cpu_scaling_policy" {
  count              = var.auto_scaler_config.enable_cpu_scaling ? 1 : 0
  name               = "${var.serviceName}_average_cpu_scaling_policy"
  service_namespace  = aws_appautoscaling_target.ecs_service_target[count.index].service_namespace
  resource_id        = aws_appautoscaling_target.ecs_service_target[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_target[count.index].scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.auto_scaler_config.cpu_scale_out_target_value
    scale_in_cooldown  = var.auto_scaler_config.cpu_scale_in_cooldown
    scale_out_cooldown = var.auto_scaler_config.cpu_scale_out_cooldown
  }
}

resource "aws_appautoscaling_policy" "ecs_memory_scaling_policy" {
  count              = var.auto_scaler_config.enable_memory_scaling ? 1 : 0
  name               = "${var.serviceName}_memory_scaling_policy"
  service_namespace  = aws_appautoscaling_target.ecs_service_target[count.index].service_namespace
  resource_id        = aws_appautoscaling_target.ecs_service_target[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_target[count.index].scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.auto_scaler_config.mem_scale_in_target_value
    scale_in_cooldown  = var.auto_scaler_config.mem_scale_in_cooldown
    scale_out_cooldown = var.auto_scaler_config.mem_scale_out_cooldown
  }
}

###########################
# Outputs
###########################

output "securityGroupId" {
  value       = aws_security_group.serviceSg.id
  description = "ID of the security group created for this ECS service"
}

output "securityGroupArn" {
  value       = aws_security_group.serviceSg.arn
  description = "ARN of the security group created for this ECS service"
}

output "securityGroupName" {
  value       = aws_security_group.serviceSg.name
  description = "Name of the security group created for this ECS service"
}

output "target_group_arn" {
  value       = aws_lb_target_group.albTargetGroup.arn
  description = "ARN of the target group for use in external listener rules or CloudFront origin"
}

output "target_group_name" {
  value       = aws_lb_target_group.albTargetGroup.name
  description = "Name of the target group"
}

output "ecs_service_name" {
  value       = aws_ecs_service.ecs_service.name
  description = "Name of the ECS service"
}

output "ecs_service_id" {
  value       = aws_ecs_service.ecs_service.id
  description = "ARN of the ECS service"
}
