variable "roleArn" {}
variable "name" {}
variable "bucketName" {}
variable "sourceCodeConnectionArn" {}
variable "repositoryFullName" {}
variable "branchName" {}
variable "deployEcs" {
  type    = bool
  default = false
}


variable "ecsClusterName" {
  type    = string
  default = "nocluster"
}
variable "ecsServiceName" {
  type    = string
  default = "noservice"
}
variable "arm64Support" {
  default = false
}
resource "aws_codepipeline" "pipeline" {
  name     = var.name
  role_arn = var.roleArn
  artifact_store {
    location = var.bucketName
    type     = "S3"
  }
  stage {
    name = "Source"

    action {

      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      namespace        = "SourceVariables"

      configuration = {
        ConnectionArn    = var.sourceCodeConnectionArn
        FullRepositoryId = var.repositoryFullName
        BranchName       = var.branchName
      }
    }
  }
  //x86 build
  dynamic "stage" {
    for_each = var.arm64Support?[] : [1]
    content {
      name = "Build"
      action {
        name             = "Build"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["source_output"]
        output_artifacts = ["build_output"]
        version          = "1"

        configuration = {
          ProjectName          = var.name
          EnvironmentVariables = jsonencode([
            {
              name  = "COMMIT_ID"
              value = "#{SourceVariables.CommitId}"
              type  = "PLAINTEXT"
            },
            {
              name  = "GIT_BRANCH"
              value = "#{SourceVariables.BranchName}"
              type  = "PLAINTEXT"
            }
          ])
        }

      }
    }
  }
  //both arm and x86
  dynamic "stage" {
    for_each = var.arm64Support?[1] : []
    content {
      name = "Build"


      action {
        name             = "Build"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["source_output"]
        output_artifacts = ["build_output"]
        version          = "1"

        configuration = {
          ProjectName          = var.name
          EnvironmentVariables = jsonencode([
            {
              name  = "COMMIT_ID"
              value = "#{SourceVariables.CommitId}"
              type  = "PLAINTEXT"
            },
            {
              name  = "GIT_BRANCH"
              value = "#{SourceVariables.BranchName}"
              type  = "PLAINTEXT"
            }
          ])
        }

      }
      action {
        name             = "Build-arm"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["source_output"]
        output_artifacts = ["build_output-arm"]
        version          = "1"

        configuration = {
          ProjectName          = "${var.name}-arm"
          EnvironmentVariables = jsonencode([
            {
              name  = "COMMIT_ID"
              value = "#{SourceVariables.CommitId}"
              type  = "PLAINTEXT"
            },
            {
              name  = "GIT_BRANCH"
              value = "#{SourceVariables.BranchName}"
              type  = "PLAINTEXT"
            }
          ])
        }

      }
    }

  }
  dynamic "stage" {
    for_each = var.arm64Support?[1] : []
    content {
      name = "BuildDockerManifest"


      action {
        name             = "DockerManifest"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["source_output"]
        output_artifacts = ["build_output_manifest"]
        version          = "1"

        configuration = {
          ProjectName          = "${var.name}-manifest"
          EnvironmentVariables = jsonencode([
            {
              name  = "COMMIT_ID"
              value = "#{SourceVariables.CommitId}"
              type  = "PLAINTEXT"
            },
            {
              name  = "GIT_BRANCH"
              value = "#{SourceVariables.BranchName}"
              type  = "PLAINTEXT"
            }
          ])
        }
      }
    }
  }
  dynamic "stage" {
    for_each = var.deployEcs==false ? [] : [1]
    content {
      name = "Deploy"
      action {
        category      = "Deploy"
        name          = "Deploy"
        owner         = "AWS"
        provider      = "ECS"
        version       = "1"
        configuration = {
          ClusterName = var.ecsClusterName
          FileName    = "taskdefinition.json"
          ServiceName = var.ecsServiceName
        }
        input_artifacts = [var.arm64Support?"build_output_manifest" : "build_output"]
      }
    }
  }
}