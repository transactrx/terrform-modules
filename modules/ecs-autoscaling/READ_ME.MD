# Terraform ECS Auto-Scaling Module

## Overview

This Terraform module provides an easy way to implement auto-scaling for Amazon ECS services based on CPU and memory utilization metrics. It allows users to optionally enable CPU-based scaling, memory-based scaling, or both, depending on their needs.

## Requirements

- Terraform v0.12 or newer
- AWS provider plugin

## Usage

Below are examples of how to use this module to enable auto-scaling based on CPU utilization, memory utilization, or both.

### Enable CPU-Based Auto-Scaling

```hcl
module "ecs_auto_scaling" {
  source = "path/to/module"

  cluster_name             = "my-cluster"
  service_name             = "my-service"
  max_capacity             = 10
  min_capacity             = 1
  enable_cpu_scaling       = true
  cpu_scale_out_target_value = 75
  cpu_scale_in_target_value  = 25
  cpu_scale_in_cooldown      = 300
  cpu_scale_out_cooldown     = 300
}
```

### Enable Memory-Based Auto-Scaling

```hcl
module "ecs_auto_scaling" { 
    source = "path/to/module"

    cluster_name                = "my-cluster"
    service_name                = "my-service"
    max_capacity                = 10
    min_capacity                = 1
    enable_memory_scaling       = true
    mem_scale_out_target_value  = 80
    mem_scale_in_target_value   = 30
    mem_scale_in_cooldown       = 300
    mem_scale_out_cooldown      = 300
}
```

### Enable Both CPU and Memory-Based Auto-Scaling

```hcl
module "ecs_auto_scaling" {
  source = "path/to/module"

  cluster_name                = "my-cluster"
  service_name                = "my-service"
  max_capacity                = 10
  min_capacity                = 1
  enable_cpu_scaling          = true
  enable_memory_scaling       = true
  cpu_scale_out_target_value  = 75
  cpu_scale_in_target_value   = 25
  cpu_scale_in_cooldown       = 300
  cpu_scale_out_cooldown      = 300
  mem_scale_out_target_value  = 80
  mem_scale_in_target_value   = 30
  mem_scale_in_cooldown       = 300
  mem_scale_out_cooldown      = 300
}
```

### Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `cluster_name` | The name of the ECS cluster. | `string` | n/a | yes |
| `service_name` | The name of the ECS service to scale. | `string` | n/a | yes |
| `max_capacity` | The maximum number of tasks the service should scale out to. | `number` | n/a | yes |
| `min_capacity` | The minimum number of tasks the service should scale in to. | `number` | n/a | yes |
| `enable_cpu_scaling` | Enable auto-scaling based on CPU utilization. | `bool` | `false` | no |
| `cpu_scale_out_target_value` | The target value for the scale out policy (e.g., CPU utilization). | `number` | n/a | yes if `enable_cpu_scaling` is `true` |
| `cpu_scale_in_target_value` | The target value for the CPU utilization to scale in. | `number` | n/a | yes if `enable_cpu_scaling` is `true` |
| `cpu_scale_in_cooldown` | The cooldown period before allowing another scale in after the last one. | `number` | `300` | no |
| `cpu_scale_out_cooldown` | The cooldown period before allowing another scale out after the last one. | `number` | `300` | no |
| `enable_memory_scaling` | Enable auto-scaling based on Memory utilization. | `bool` | `false` | no |
| `mem_scale_out_target_value` | The target value for the scale out policy (e.g., Memory utilization). | `number` | n/a | yes if `enable_memory_scaling` is `true` |
| `mem_scale_in_target_value` | The target value for the Memory utilization to scale in. | `number` | n/a | yes if `enable_memory_scaling` is `true` |
| `mem_scale_in_cooldown` | The cooldown period before allowing another scale in after the last one. | `number` | `300` | no |
| `mem_scale_out_cooldown` | The cooldown period before allowing another scale out after the last one. | `number` | `300` | no |

### Outputs
| Name | Description |
|------|-------------|
| `ecs_service_target_id` | The ID of the ECS service scaling target. |
| `cpu_scaling_policy_arn` | The ARN of the CPU based auto-scaling policy, if enabled. |
| `memory_scaling_policy_arn` | The ARN of the memory based auto-scaling policy, if enabled. |
