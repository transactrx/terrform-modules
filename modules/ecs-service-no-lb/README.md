# ecs-service-no-lb

ECS service without a load balancer. Use for background workers, internal services, or tasks that don't need inbound traffic.

## Usage

```hcl
module "worker" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/ecs-service-no-lb"

  # ... see inputs below
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
