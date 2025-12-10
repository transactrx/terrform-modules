variable "imageURL" {
  type = string
}
variable "envVariables" {
  type = list(object({
    value = string
    name  = string
  }))
  default = null
}

variable "portMappings" {
  type = list(object({
    containerPort = number
    protocol      = optional(string, "tcp")
  }))
  default = null
}

variable "secrets" {
  type = list(object({
    valueFrom = string
    name      = string
  }))
  default = null
}


variable "containerName" {
  type = string
}
variable "cpu" {
  type = number
}
variable "memory" {
  type = number
}
variable "essential" {
  type    = bool
  default = true
}
variable "logGroup" {
  type    = string
  default = ""
}
variable "logIsBlocking" {
  type = bool
  default = false
}
data "aws_region" "current" {}

variable "dependsOn" {
  type = list(object({
    condition     = string
    containerName = string
  }))
  default = null
}

variable "volumesFrom" {
  type = list(object({
    sourceContainer = string
    readOnly        = optional(bool, false)
  }))
  default = null
}

locals {
  containerDefinition = {
    name             = var.containerName
    image            = var.imageURL
    cpu              = var.cpu
    memory           = var.memory
    essential        = var.essential
    logConfiguration = var.logGroup==""?null : {
      logDriver = "awslogs"
      options   = {
        awslogs-group         = var.logGroup
        awslogs-region        = data.aws_region.current.region
        awslogs-stream-prefix = var.containerName
        mode = var.logIsBlocking ? "blocking":"non-blocking"
      }
    }
    environment  = var.envVariables
    portMappings = var.portMappings
    secrets      = var.secrets
    dependsOn    = var.dependsOn
    volumesFrom  = var.volumesFrom
  }
}

output "ContainerDefString" {
  value = jsonencode(local.containerDefinition)
}
output "ContainerDefObject" {
  value = local.containerDefinition
}