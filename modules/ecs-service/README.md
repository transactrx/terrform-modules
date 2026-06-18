# ecs-service

Basic ECS service with load balancer support.

> **Note:** For new deployments, consider using `ecs-service-with-alb` or `ecs-service-with-target-group` instead.

## Usage

```hcl
module "service" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/ecs-service"

  # ... see inputs below
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
