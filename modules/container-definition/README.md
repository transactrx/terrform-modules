# container-definition

Container definition builder for ECS task definitions.

## Usage

```hcl
module "container" {
  source = "git::git@github.com:transactrx/terrform-modules.git//modules/container-definition"

  # ... see inputs below
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_containerName"></a> [containerName](#input\_containerName) | n/a | `string` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | n/a | `number` | n/a | yes |
| <a name="input_dependsOn"></a> [dependsOn](#input\_dependsOn) | n/a | <pre>list(object({<br/>    condition     = string<br/>    containerName = string<br/>  }))</pre> | `null` | no |
| <a name="input_envVariables"></a> [envVariables](#input\_envVariables) | n/a | <pre>list(object({<br/>    value = string<br/>    name  = string<br/>  }))</pre> | `null` | no |
| <a name="input_essential"></a> [essential](#input\_essential) | n/a | `bool` | `true` | no |
| <a name="input_imageURL"></a> [imageURL](#input\_imageURL) | n/a | `string` | n/a | yes |
| <a name="input_logGroup"></a> [logGroup](#input\_logGroup) | n/a | `string` | `""` | no |
| <a name="input_logIsBlocking"></a> [logIsBlocking](#input\_logIsBlocking) | n/a | `bool` | `false` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | n/a | `number` | n/a | yes |
| <a name="input_portMappings"></a> [portMappings](#input\_portMappings) | n/a | <pre>list(object({<br/>    containerPort = number<br/>    protocol      = optional(string, "tcp")<br/>  }))</pre> | `null` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | n/a | <pre>list(object({<br/>    valueFrom = string<br/>    name      = string<br/>  }))</pre> | `null` | no |
| <a name="input_stopTimeout"></a> [stopTimeout](#input\_stopTimeout) | Seconds to wait before the container is forcefully killed (SIGKILL) after SIGTERM. Max 120 for Fargate. | `number` | `null` | no |
| <a name="input_ulimits"></a> [ulimits](#input\_ulimits) | Container ulimit settings. Useful for increasing file descriptor limits for high-connection workloads. | <pre>list(object({<br/>    name      = string<br/>    softLimit = number<br/>    hardLimit = number<br/>  }))</pre> | `null` | no |
| <a name="input_volumesFrom"></a> [volumesFrom](#input\_volumesFrom) | n/a | <pre>list(object({<br/>    sourceContainer = string<br/>    readOnly        = optional(bool, false)<br/>  }))</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ContainerDefObject"></a> [ContainerDefObject](#output\_ContainerDefObject) | n/a |
| <a name="output_ContainerDefString"></a> [ContainerDefString](#output\_ContainerDefString) | n/a |
<!-- END_TF_DOCS -->
