# account-modules

Account-level infrastructure modules. These modules are designed for setting up foundational AWS resources within an account.

## Modules

| Module | Description |
|--------|-------------|
| [alb-private](./alb-private) | Private Application Load Balancer |
| [alb-public](./alb-public) | Public Application Load Balancer |
| [aurora-postgres](./aurora-postgres) | Aurora PostgreSQL cluster |
| [bastion_role](./bastion_role) | Bastion host IAM role |
| [certificate](./certificate) | ACM certificate |
| [cloudfront-dist](./cloudfront-dist) | CloudFront distribution |
| [cloudfront-dist-vpc-origin](./cloudfront-dist-vpc-origin) | CloudFront distribution with VPC origin |
| [ecs](./ecs) | ECS cluster |
| [ecs-service-with-alb](./ecs-service-with-alb) | ECS service with ALB |
| [ecs-service-with-nlb](./ecs-service-with-nlb) | ECS service with NLB |
| [github-actions-support](./github-actions-support) | GitHub Actions OIDC and IAM setup |
| [nlb](./nlb) | Network Load Balancer |
| [sequence_manager](./sequence_manager) | Sequence manager |
| [task-definition](./task-definition) | ECS task definition |
| [twingate-vpn](./twingate-vpn) | Twingate VPN connector |
| [vpc](./vpc) | VPC and networking |

## Usage

```hcl
module "example" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/account-modules/<module-name>"

  # ... module inputs
}
```
