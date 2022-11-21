variable "codeBuildRoleArn" {
  type = string
}
variable "codePipelineRoleArn" {
  type = string
}
variable "codePipelineS3BucketName" {
  type = string
}
variable "dockerHubCredSecretArn" {
  type = string
}
variable "gitHubTokenSecretManagerArn" {
  type = string
}
variable "githubConnectionArn" {
  type = string
}
variable "deploySubnets" {
  type = list(string)
}

variable "githubBranch" {
  type = string
}
variable "serviceName" {}
variable "githubURL" {
  type = string
}
variable "vpcId" {
  type = string
}
variable "containerList" {
}
variable "ecsClusterName" {
}
variable "desiredCount" {
  type = number
}
module "codePipeline" {
  source                      = "../cdspipeline"
  branchName                  = var.githubBranch
  clusterName                 = var.ecsClusterName
  codeBuildLogGroupName       = "/codebuild/${var.serviceName}"
  codeBuildRoleArn            = var.codeBuildRoleArn
  codePipelineRoleArn         = var.codePipelineRoleArn
  codePipelineS3BucketName    = var.codePipelineS3BucketName
  dockerHubCredSecretArn      = var.dockerHubCredSecretArn
  gitHubTokenSecretManagerArn = var.gitHubTokenSecretManagerArn
  gitHubURL                   = var.githubURL
  githubConnectionArn         = var.githubConnectionArn
  serviceName                 = var.serviceName
  addEcsToCodeDeploy          = true
}

resource "aws_cloudwatch_log_group" "pwl-tcp-server-test-log-group" {
  name              = module.codePipeline.serviceName
  retention_in_days = 30
}


variable "CPU" {
  type = number
  default = 512
}
variable "Memory" {
    type = number
    default = 1024
}
module "pwl-tcp-server-testTaskDef" {
  source        = "../task-definition"
  CPU           = var.CPU
  ContainerList = var.containerList
  Memory        = var.Memory
  taskDefFamily = module.codePipeline.serviceName
  mainImageURL  = "${module.codePipeline.imageUrl}:latest"
}


