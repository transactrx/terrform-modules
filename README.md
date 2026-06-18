# Terraform Modules

Shared Terraform modules for TransactRx infrastructure.

## Usage

Reference modules using the Git source:

```hcl
module "example" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/<module-name>?ref=<tag-or-branch>"
  
  # ... module inputs
}
```

## Modules

### ECS Services

| Module | Description | When to Use |
|--------|-------------|-------------|
| [ecs-service-with-alb](./modules/ecs-service-with-alb) | ECS service with ALB listener rules and Route53 DNS | Standard web services with direct ALB routing |
| [ecs-service-with-target-group](./modules/ecs-service-with-target-group) | ECS service with target group and optional routing/DNS | Services behind CloudFront, or when DNS/routing is managed elsewhere |
| [ecs-service](./modules/ecs-service) | Basic ECS service with load balancer | Legacy - prefer `ecs-service-with-alb` |
| [ecs-service-no-lb](./modules/ecs-service-no-lb) | ECS service without load balancer | Background workers, internal services |
| [ecs-task](./modules/ecs-task) | ECS task definition | Standalone task definitions |
| [task-definition](./modules/task-definition) | Task definition builder | Task definition construction |
| [container-definition](./modules/container-definition) | Container definition builder | Container definition JSON |

### Load Balancers

| Module | Description |
|--------|-------------|
| [alb](./modules/alb) | Application Load Balancer |
| [nlb](./modules/nlb) | Network Load Balancer |

### CloudFront

| Module | Description |
|--------|-------------|
| [cloudfront-to-public-alb](./modules/cloudfront-to-public-alb) | CloudFront distribution with public ALB origin |
| [cloudfront-to-private-alb](./modules/cloudfront-to-private-alb) | CloudFront distribution with private ALB origin |

### Database (DSQL)

| Module | Description |
|--------|-------------|
| [dsql-cluster](./modules/dsql-cluster) | Aurora DSQL cluster |
| [dsql-backup](./modules/dsql-backup) | DSQL backup configuration |
| [dsql-service-endpoints](./modules/dsql-service-endpoints) | DSQL VPC endpoints |

### CI/CD

| Module | Description |
|--------|-------------|
| [cdspipeline](./modules/cdspipeline) | CodePipeline setup |
| [codePiplineDependencies](./modules/codePiplineDependencies) | CodePipeline supporting resources |

### Account

| Module | Description |
|--------|-------------|
| [account-modules](./modules/account-modules) | Account-level infrastructure modules |

## Module Documentation

Each module contains an auto-generated README with full input/output documentation. Click the module links above to view details.

## Contributing

1. Create a feature branch
2. Make changes to module `.tf` files
3. Push - GitHub Actions will auto-generate module READMEs
4. Create PR for review
