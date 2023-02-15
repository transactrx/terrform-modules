variable "serviceName" {}
variable "dockerHubCredSecretArn" {}
variable "codeBuildRoleArn" {}
variable "gitHubURL" {}
variable "gitHubTokenSecretManagerArn" {}
variable "useDefaultBuildSpec" {
  default = true
}
variable "codePipelineS3BucketName" {
}
variable "codePipelineRoleArn" {
}
variable "githubConnectionArn" {
}
variable "branchName" {
}
variable "clusterName" {
}


variable "codeBuildLogGroupName" {
}
variable "addEcsToCodeDeploy" { default = false }
variable "tomcatDownloadLocation" {
  default = ""
}
variable "arm64Support" {
  default = false
}
variable "buildVariables" {
  type = list(object({
    name  = string
    value = string
    type  = string
  }))
  default = []
}

data "aws_secretsmanager_secret" "dockerhubCreds" {
  arn = var.dockerHubCredSecretArn
}
data "aws_secretsmanager_secret" "gitHubAccessToken" {
  arn = var.gitHubTokenSecretManagerArn
}

locals {
  fullName = "ecs-${var.serviceName}"
}
data "aws_caller_identity" "current" {
  # no arguments
}


//codeBuildRoleArn=module.codePipelineDepsProd.codeBuildRoleArn
//codeBuildRoleName=module.codePipelineDepsProd.codeBuildRoleName
//codePipelineRoleArn=module.codePipelineDepsProd.codePipelineRoleArn
//codePipelineRoleName=module.codePipelineDepsProd.codePipelineRoleName
//codePipeLineS3Arn=module.codePipelineDepsProd.codePipeLineS3Arn
//codePipeLineS3Bucket=module.codePipelineDepsProd.codePipelineS3Bucket





module "codebuild" {
  source                 = "./codebuild"
  codebuildRoleArn       = var.codeBuildRoleArn
  gitURL                 = "https://github.com/${var.gitHubURL}"
  name                   = var.serviceName
  dockerHubCredentials   = data.aws_secretsmanager_secret.dockerhubCreds.name
  githubAccessToken      = data.aws_secretsmanager_secret.gitHubAccessToken.name
  tomcatDownloadLocation = var.tomcatDownloadLocation
  logGroupName           = var.codeBuildLogGroupName
  useDefaultBuildSpec    = var.useDefaultBuildSpec
  arm64Support           = var.arm64Support
  buildVariables         = var.buildVariables
}


module "codepipeline" {
  source = "./codepipeline"

  bucketName              = var.codePipelineS3BucketName
  name                    = local.fullName
  repositoryFullName      = var.gitHubURL
  roleArn                 = var.codePipelineRoleArn
  sourceCodeConnectionArn = var.githubConnectionArn
  deployEcs               = var.addEcsToCodeDeploy
  ecsClusterName          = var.clusterName
  ecsServiceName          = var.serviceName
  branchName              = var.branchName
  arm64Support            = var.arm64Support

}

output "imageUrl" {
  value = module.codebuild.codebuildRepositoryUrl
}

output "serviceName" {
  value = var.serviceName
}