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
<!-- END_TF_DOCS -->
