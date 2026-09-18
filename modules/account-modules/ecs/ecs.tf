variable "name" {

}

variable "container_insights" {
  description = "containerInsights cluster setting: disabled, enabled or enhanced. Leave null to not manage the setting at all, which is how this module behaved before the variable existed."
  type        = string
  default     = null

  validation {
    condition     = var.container_insights == null ? true : contains(["disabled", "enabled", "enhanced"], var.container_insights)
    error_message = "container_insights must be disabled, enabled or enhanced."
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = var.name

  # Omitted entirely when container_insights is null, so clusters that already
  # carry a containerInsights value keep it and continue to plan clean.
  dynamic "setting" {
    for_each = var.container_insights == null ? [] : [var.container_insights]
    content {
      name  = "containerInsights"
      value = setting.value
    }
  }
}
resource "aws_ecs_cluster_capacity_providers" "cluster-capacity" {
  cluster_name       = aws_ecs_cluster.cluster.name
  capacity_providers = ["FARGATE_SPOT", "FARGATE"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 3
    base              = 0
  }

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}
output "name" {
  value = aws_ecs_cluster.cluster.name
}
