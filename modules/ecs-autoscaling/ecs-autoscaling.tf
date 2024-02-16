variable "cluster_name" {
  description = "The name of the ECS cluster."
  type        = string
}

variable "service_name" {
  description = "The name of the ECS service to scale."
  type        = string
}

variable "max_capacity" {
  description = "The maximum number of tasks the service should scale out to."
  type        = number
}

variable "min_capacity" {
  description = "The minimum number of tasks the service should scale in to."
  type        = number
}

variable "scale_out_target_value" {
  description = "The target value for the scale out policy (e.g., CPU utilization)."
  type        = number
}

variable "scale_in_target_value" {
  description = "The target value for the CPU utilization to scale in."
  type        = number
}

variable "scale_in_cooldown" {
  description = "The cooldown period before allowing another scale in after the last one."
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "The cooldown period before allowing another scale out after the last one."
  type        = number
  default     = 300
}

resource "aws_appautoscaling_target" "ecs_service_target" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale_out_policy" {
  name               = "${var.service_name}_scale_out"
  service_namespace  = aws_appautoscaling_target.ecs_service_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_service_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.scale_out_target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}

resource "aws_appautoscaling_policy" "scale_in_policy" {
  name               = "${var.service_name}_scale_in"
  service_namespace  = aws_appautoscaling_target.ecs_service_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_service_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.scale_in_target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}
