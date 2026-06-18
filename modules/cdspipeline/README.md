# cdspipeline

AWS CodePipeline modules for CI/CD infrastructure.

## Modules

| Module | Description |
|--------|-------------|
| [codebuild](./codebuild) | CodeBuild project configuration |
| [codepipeline](./codepipeline) | CodePipeline configuration |
| [policies](./policies) | IAM policies for CI/CD |
| [roles](./roles) | IAM roles for CI/CD |

## Usage

```hcl
module "pipeline" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/cdspipeline"

  # ... module inputs
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
