# ecs-service-with-alb

ECS service with ALB listener rules and Route53 DNS records. Creates a complete routing stack for web services.

## Usage

```hcl
module "api_service" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/ecs-service-with-alb"

  serviceName        = "my-api"
  clusterName        = "prod-cluster"
  vpc_id             = var.vpc_id
  subNets            = var.private_subnet_ids
  desiredCount       = 2
  taskDefinitionFull = aws_ecs_task_definition.api.arn
  dnsName            = "api.example.com"

  applicationLoadBalancerAttachment = {
    containerName   = "api"
    containerPort   = 8080
    protocol        = "HTTP"
    lbArn           = var.alb_arn
    listenerArn     = var.https_listener_arn
    publicHostName  = "api.example.com"
    healthCheckPath = "/health"
    rulePriority    = 100
  }
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
