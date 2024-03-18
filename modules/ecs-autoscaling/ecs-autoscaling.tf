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

variable "enable_cpu_scaling" {
  description = "Enable auto-scaling based on CPU utilization."
  type        = bool
  default     = false
}

variable "cpu_scale_out_target_value" {
  description = "The target value for the scale out policy (e.g., CPU utilization)."
  type        = number
  default     = 80
}

variable "cpu_scale_in_target_value" {
  description = "The target value for the CPU utilization to scale in."
  type        = number
  default     = 60
}

variable "cpu_scale_in_cooldown" {
  description = "The cooldown period before allowing another scale in after the last one."
  type        = number
  default     = 120
}

variable "cpu_scale_out_cooldown" {
  description = "The cooldown period before allowing another scale out after the last one."
  type        = number
  default     = 120
}

variable "enable_memory_scaling" {
  description = "Enable auto-scaling based on Memory utilization."
  type        = bool
  default     = false
}

variable "mem_scale_out_target_value" {
  description = "The target value for the scale out policy (e.g., Memory utilization)."
  type        = number
  default     = 80
}

variable "mem_scale_in_target_value" {
  description = "The target value for the Memory utilization to scale in."
  type        = number
  default     = 60
}

variable "mem_scale_in_cooldown" {
  description = "The cooldown period before allowing another scale in after the last one."
  type        = number
  default     = 120
}

variable "mem_scale_out_cooldown" {
  description = "The cooldown period before allowing another scale out after the last one."
  type        = number
  default     = 120
}

resource "aws_appautoscaling_target" "ecs_service_target" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_average_cpu_scaling_policy" {
  count              = var.enable_cpu_scaling ? 1 : 0
  name               = "${var.service_name}_average_cpu_scaling_policy"
  service_namespace  = aws_appautoscaling_target.ecs_service_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_service_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_scale_out_target_value
    scale_in_cooldown  = var.cpu_scale_in_cooldown
    scale_out_cooldown = var.cpu_scale_out_cooldown
  }
}

resource "aws_appautoscaling_policy" "ecs_memory_scaling_policy" {
  count              = var.enable_memory_scaling ? 1 : 0
  name               = "${var.service_name}_memory_scaling_policy"
  service_namespace  = aws_appautoscaling_target.ecs_service_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_service_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.mem_scale_in_target_value
    scale_in_cooldown  = var.mem_scale_in_cooldown
    scale_out_cooldown = var.mem_scale_out_cooldown
  }
}
