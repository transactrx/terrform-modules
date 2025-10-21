###########################
# Variables
###########################

variable "serviceName" {
  type        = string
  description = "ECS Service Name"
}

variable "clusterName" {
  type = string
}

variable "deploymentMaxPercent" {
  type    = number
  default = 200
}

variable "subNets" {
  type = list(string)
}

variable "taskDefinitionFull" {}

variable "desiredCount" {
  type = number
}

variable "vpc_id" {
  type = string
}

variable "dnsName" {
  type        = string
  description = "FQDN for DNS record (optional if Route53 record creation disabled)"
  default     = null
}

variable "create_route53_record" {
  description = "Whether to create a Route53 DNS record"
  type        = bool
  default     = true
}

locals {
  dns_parts = var.dnsName != null ? split(".", var.dnsName) : []
  zone_name = length(local.dns_parts) >= 2 ? join(".", slice(local.dns_parts, length(local.dns_parts) - 2, length(local.dns_parts))) : ""
}

data "aws_route53_zone" "public" {
  count        = var.create_route53_record && var.dnsName != null ? 1 : 0
  name         = local.zone_name
  private_zone = false
}

data "aws_lb" "alb" {
  arn = var.applicationLoadBalancerAttachment.lbArn
}

###########################
# Route53 Record (Conditional)
###########################

resource "aws_route53_record" "app_dns" {
  count = var.create_route53_record && var.dnsName != null ? 1 : 0

  zone_id = data.aws_route53_zone.public[0].zone_id
  name    = var.dnsName
  type    = "A"

  alias {
    name                   = data.aws_lb.alb.dns_name
    zone_id                = data.aws_lb.alb.zone_id
    evaluate_target_health = false
  }
}

###########################
# ALB Attachments and Config
###########################

variable "applicationLoadBalancerAttachment" {
  type = object({
    containerName       = string
    containerPort       = number
    protocol            = string
    lbArn               = string
    listenerArn         = string
    lbPort              = number
    certificateArn      = optional(string)
    name                = optional(string)
    healthCheckPath     = optional(string)
    rulePriority        = optional(number)
    pathPattern         = optional(string)
    publicHostName      = string
    healthy_threshold   = optional(number)
    unhealthy_threshold = optional(number)
    matcher             = optional(string)
    interval            = optional(number)
    timeout             = optional(number)
  })

  default = {
    containerName       = null
    containerPort       = null
    protocol            = null
    lbArn               = null
    lbPort              = null
    certificateArn      = null
    name                = null
    healthCheckPath     = null
    rulePriority        = null
    pathPattern         = null
    publicHostName      = null
    listenerArn         = null
    healthy_threshold   = null
    unhealthy_threshold = null
    matcher             = null
    interval            = null
    timeout             = null
  }
}

variable "alb_service_protocol" {
  description = "Protocol for the ALB target group and health check"
  type        = string
  default     = "HTTP"
}

variable "auto_scaler_config" {
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
# Data Sources and Locals
###########################

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

locals {
  containerPortToBeOpen = var.applicationLoadBalancerAttachment.containerPort

  # 🧩 SAFE target group name (prevents trailing "-")
  _raw_tg_name = (
  var.applicationLoadBalancerAttachment.name != null ?
  "${var.serviceName}-${var.applicationLoadBalancerAttachment.name}" :
  "${var.serviceName}-${var.applicationLoadBalancerAttachment.containerName}-${var.applicationLoadBalancerAttachment.containerPort}"
  )

  safe_target_group_name = trim(substr(local._raw_tg_name, 0, 32), "-")

  # 🧩 SAFE security group name (same logic)
  safe_security_group_name = trim(substr("${var.serviceName}", 0, 32), "-")
}

###########################
# Security Group and Rules
###########################

resource "aws_security_group" "serviceSg" {
  name   = local.safe_security_group_name
  vpc_id = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
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

###########################
# ALB Target Groups
###########################

resource "aws_lb_target_group" "albTargetGroup" {
  protocol    = var.applicationLoadBalancerAttachment.protocol
  target_type = "ip"
  name        = local.safe_target_group_name
  deregistration_delay = 120
  port                 = var.applicationLoadBalancerAttachment.containerPort

  health_check {
    protocol            = var.applicationLoadBalancerAttachment.protocol
    path                = (var.applicationLoadBalancerAttachment.healthCheckPath != null ? var.applicationLoadBalancerAttachment.healthCheckPath : "/")
    healthy_threshold   = try(var.applicationLoadBalancerAttachment.healthy_threshold, 5)
    unhealthy_threshold = try(var.applicationLoadBalancerAttachment.unhealthy_threshold, 5)
    matcher             = try(var.applicationLoadBalancerAttachment.matcher, "200-399")
    interval            = try(var.applicationLoadBalancerAttachment.interval, 30)
    timeout             = try(var.applicationLoadBalancerAttachment.timeout, 5)
  }

  vpc_id = var.vpc_id
}

###########################
# ALB Listeners and Rules
###########################

resource "aws_lb_listener_rule" "albListenerRule" {
  listener_arn = var.applicationLoadBalancerAttachment.listenerArn
  priority     = var.applicationLoadBalancerAttachment.rulePriority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.albTargetGroup.arn
  }

  dynamic "condition" {
    for_each = (
    var.applicationLoadBalancerAttachment.pathPattern != null &&
    trim(tostring(var.applicationLoadBalancerAttachment.pathPattern), "/") != ""
    ) ? [1] : []

    content {
      path_pattern {
        values = [var.applicationLoadBalancerAttachment.pathPattern]
      }
    }
  }

  condition {
    host_header {
      values = [var.applicationLoadBalancerAttachment.publicHostName]
    }
  }
}

###########################
# ECS Service
###########################

resource "aws_ecs_service" "ecs_service" {
  name                       = var.serviceName
  cluster                    = var.clusterName
  deployment_maximum_percent = var.deploymentMaxPercent
  desired_count              = var.desiredCount
  task_definition            = var.taskDefinitionFull

  dynamic "load_balancer" {
    for_each = aws_lb_target_group.albTargetGroup
    content {
      container_name   = var.applicationLoadBalancerAttachment.containerName
      container_port   = var.applicationLoadBalancerAttachment.containerPort
      target_group_arn = aws_lb_target_group.albTargetGroup.arn
    }
  }

  network_configuration {
    subnets         = var.subNets
    security_groups = [aws_security_group.serviceSg.id]
  }

  lifecycle {
    ignore_changes = [capacity_provider_strategy]
  }
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
  value = aws_security_group.serviceSg.id
}

output "securityGroupArn" {
  value = aws_security_group.serviceSg.arn
}

output "securityGroupName" {
  value = aws_security_group.serviceSg.name
}

output "targetGroupName" {
  value = local.safe_target_group_name
}