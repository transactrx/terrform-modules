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

variable "applicationLoadBalancerAttachments" {
  type = list(
    object({
      containerName   = string
      containerPort   = number
      protocol        = string
      lbArn           = string
      lbPort          = number
      certificateArn  = optional(string)
      name            = optional(string)
      healthCheckPath = optional(string)
      rulePriority    = optional(number)
      pathPattern     = optional(string)
    })
  )
  default = [{
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
  }]
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

data "aws_lb" "alb" {
  count = length(var.applicationLoadBalancerAttachments)
  arn   = var.applicationLoadBalancerAttachments[count.index].lbArn
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

locals {
  containerPortsToBeOpen = distinct(var.applicationLoadBalancerAttachments.*.containerPort)
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
}

resource "aws_security_group_rule" "sgRules" {
  count             = length(local.containerPortsToBeOpen)
  from_port         = local.containerPortsToBeOpen[count.index]
  protocol          = "TCP"
  security_group_id = aws_security_group.serviceSg.id
  to_port           = local.containerPortsToBeOpen[count.index]
  type              = "ingress"
  cidr_blocks       = [data.aws_vpc.vpc.cidr_block]
  description       = "Allow traffic from within VPC"
}

###########################
# ALB Target Groups
###########################

resource "aws_lb_target_group" "albTargetGroup" {
  count       = length(var.applicationLoadBalancerAttachments)
  protocol    = var.alb_service_protocol
  target_type = "ip"
  name        = var.applicationLoadBalancerAttachments[count.index].name != null ?
                "${var.serviceName}-${var.applicationLoadBalancerAttachments[count.index].name}" :
                "${var.serviceName}-${var.applicationLoadBalancerAttachments[count.index].containerName}-${var.applicationLoadBalancerAttachments[count.index].containerPort}"
  deregistration_delay = 120
  port                 = var.applicationLoadBalancerAttachments[count.index].containerPort

  health_check {
    protocol            = var.alb_service_protocol
    path                = var.applicationLoadBalancerAttachments[count.index].healthCheckPath != null ?
                          var.applicationLoadBalancerAttachments[count.index].healthCheckPath : "/"
    healthy_threshold   = 5
    unhealthy_threshold = 5
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
  }
  vpc_id = var.vpc_id
}

###########################
# ALB Listeners and Rules
###########################

resource "aws_lb_listener" "albListeners" {
  count             = length(var.applicationLoadBalancerAttachments)
  load_balancer_arn = var.applicationLoadBalancerAttachments[count.index].lbArn
  port              = var.applicationLoadBalancerAttachments[count.index].lbPort
  protocol          = var.applicationLoadBalancerAttachments[count.index].protocol

  certificate_arn   = lower(var.applicationLoadBalancerAttachments[count.index].protocol) == "https" ?
                      var.applicationLoadBalancerAttachments[count.index].certificateArn : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.albTargetGroup[count.index].arn
  }
}

resource "aws_lb_listener_rule" "albListenerRule" {
  count        = length(var.applicationLoadBalancerAttachments)
  listener_arn = aws_lb_listener.albListeners[count.index].arn

  # Use provided rulePriority or default to a unique value (starting at 100).
  priority = var.applicationLoadBalancerAttachments[count.index].rulePriority != null ?
             var.applicationLoadBalancerAttachments[count.index].rulePriority : count.index + 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.albTargetGroup[count.index].arn
  }

  condition {
    path_pattern {
      values = [
        var.applicationLoadBalancerAttachments[count.index].pathPattern != null ?
        var.applicationLoadBalancerAttachments[count.index].pathPattern : "/*"
      ]
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
      container_name   = var.applicationLoadBalancerAttachments[load_balancer.key].containerName
      container_port   = var.applicationLoadBalancerAttachments[load_balancer.key].containerPort
      target_group_arn = aws_lb_target_group.albTargetGroup[load_balancer.key].arn
    }
  }

  network_configuration {
    subnets         = var.subNets
    security_groups = [aws_security_group.serviceSg.id]
  }

  lifecycle {
    ignore_changes = [
      "capacity_provider_strategy"
    ]
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