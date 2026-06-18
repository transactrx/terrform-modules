# cloudfront-to-private-alb

CloudFront distribution with a private ALB origin (via VPC origin).

## Usage

```hcl
module "cdn" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/cloudfront-to-private-alb"

  # ... see inputs below
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
