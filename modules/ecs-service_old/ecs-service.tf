variable "serviceName" {

}

variable "useMongoConnection" {
  default = false
  type    = bool
}
variable "ephemeralStorage" {
  type    = number
  default = 0
}
variable "useNoAuthPgBouncer" {
  default = false
  type    = bool
}


variable "preserveLog" {
  default = false
  type    = bool
}
variable "additionalEnvVars" {
  type    = map
  default = {}
}
variable "additionSecrets" {
  type    = map
  default = {}
}
variable "useMail" {
  default = true
}
variable "usePgBouncer" {
  default = true
}
variable "useStunnel" {
  default = true
}
variable "useWaf" {
  default = true
}
variable "useAppProxy" {
  default = false
}
variable "useArm" {
  default = false
  type    = bool
}
variable "listenerPriority" {
  type    = number
  default = 0
}
variable "addEcsToCodeDeploy" {
  default = true
}
variable "dockerHubCredSecretArn" {}
variable "ecsMainImageUri" {}
variable "servicePort" {
  default = "8080"
}
variable "healthCheckPath" {
  default = ""
}
variable "taskMemoryMb" {
  default = 2048
}
variable "additionalContainers" {
  default = []
}
variable "additionalMemory" {
  default = 0
}
variable "additionalCPU" {
  default = 0
}
variable "taskCPU" {
  default = 256
}
variable "desiredCount" {
  type = number
}


variable "listenerPath" {
  default = []
  type    = list(string)
}
variable "listenerHosts" {
  type    = list(string)
  default = []
}
variable volumeFrom {
  default = []
}
variable volumes {
  default = []
}
variable mountPoints {
  default = []
  type    = list(object({
    containerPath = string
    readOnly      = bool
    sourceVolume  = string
  }))
}
variable "nlb" {
  default = false
}
variable "nlbPorts" {
  default = []
  type    = list(object({
    servicePort   = number
    protocol      = string
    nlbPort       = number
    containerName = string
  }))
}
variable "nlbHealthCheckPort" {
  default = 0
  type    = number
}
variable "deploymentType" {
  default = "FARGATE"
}
variable "envPostFix" {
  default = ""
}
variable "cluster" {
}
variable "networkLbProtocol" {
  default = "TCP"
}

variable "connectToLB" {
  type = bool
}
variable "privileged" {
  default = false
}

variable "networkLbCertificateArn" {
  default = null
}

variable "scheduleCron" {
  default = ""
  type    = string
}
variable "lbListenerArn" {
  default = ""
}
variable "albSgId" {
  default = ""
}

variable "publicDomain" {
  default = ""
}
variable "NLBArn" {
  default = ""
}
module "ecs" {
  source            = "./ecs"
  additionalEnvVars = var.additionalEnvVars
  AdditionalSecrets = var.additionSecrets
  appName           = var.serviceName
  awsLogGroup       = "/ecs/${var.serviceName}"
  ecsImage          = var.ecsMainImageUri
  servicePort       = var.servicePort
  useMail           = var.useMail
  usePgBouncer      = var.usePgBouncer
  useStunnel        = var.useStunnel
  serviceName       = var.serviceName
  cluster           = var.cluster
  healthCheckPath   = var.healthCheckPath
  listenerArn       = var.lbListenerArn
  listenerPriority  = var.listenerPriority
  albSgId           = var.albSgId

  taskMemoryMb            = var.taskMemoryMb
  taskCPU                 = var.taskCPU
  desiredCount            = var.desiredCount
  listenerPath            = var.listenerPath
  additionalContainers    = var.additionalContainers
  additionalCPU           = var.additionalCPU
  additionalMemory        = var.additionalMemory
  volumeFrom              = var.volumeFrom
  volumes                 = var.volumes
  mountPoints             = var.mountPoints
  publicDomain            = var.publicDomain
  preserveLog             = var.preserveLog
  listenerHosts           = var.listenerHosts
  useWaf                  = var.useWaf
  useAppProxy             = var.useAppProxy
  nlb                     = var.nlb
  nlbPorts                = var.nlbPorts
  nlbHealthCheckPort      = var.nlbHealthCheckPort
  deploymentType          = var.deploymentType
  envPostFix              = var.envPostFix
  networkLbProtocol       = var.networkLbProtocol
  useNoAuthPgBouncer      = var.useNoAuthPgBouncer
  connectToLB             = var.connectToLB
  privileged              = var.privileged
  networkLbCertificateArn = var.networkLbCertificateArn
  scheduleCron            = var.scheduleCron
  useMongoConnection      = var.useMongoConnection
  ephemeralStorage        = var.ephemeralStorage
  useArm                  = var.useArm

  NLBArn = var.NLBArn
}

output "taskRoleArn" {
  value = module.ecs.taskRoleArn
}
output "taskRoleName" {
  value = module.ecs.taskRoleName
}

output "taskExecutionRoleArn" {
  value = module.ecs.taskExecutionRoleArn
}
output "taskExecutionRoleName" {
  value = module.ecs.taskExecutionRoleName
}
