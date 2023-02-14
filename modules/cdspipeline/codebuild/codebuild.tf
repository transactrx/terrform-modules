variable "dockerHubCredentials" {
}
variable "githubAccessToken" {}
variable "NugetPat" {
  type = string
}
variable "arm64Support" {
  default = false
}

variable "gitURL" {
  type = string
}
variable "name" {
  type = string
}
variable "codebuildRoleArn" {
  type = string
}
variable "useDefaultBuildSpec" {
  default = false
}

resource "aws_ecr_repository" "ecrRepo" {
  name = join("/", ["trx-repo", var.name])
  image_scanning_configuration {
    scan_on_push = true
  }
}
variable "tomcatDownloadLocation" {}
variable "logGroupName" {
  type = string
}

variable "buildVariables" {
  type = list(object({
    name  = string
    value = string
    type  = string
  }))
  default = []
}

locals {
  defaultBuildSpec = <<DEFINITION
version: 0.2

phases:
  install:
    commands:
      - echo Logging in to Amazon ECR...
      - $(aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION)
  pre_build:
    commands:
      - export ACCOUNTID=`echo $CODEBUILD_KMS_KEY_ID|awk -F':' '{print $5}'`
      - echo "accountid=$ACCOUNTID"
      - COMMIT_HASH=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
      - export IMAGE_TAG=build-$(echo $CODEBUILD_BUILD_ID | awk -F":" '{print $2}')
      - echo "image tag $IMAGE_TAG"
      - export CURRENT_BRANCH=`git branch --show-current`
      - export COMMIT_HASH=`git rev-parse --verify $CURRENT_BRANCH`
  build:
    commands:
      - export PROJECTNAME="${var.name}"
      - export ARCH=`uname -p`
      - export VERSION="$COMMIT_ID-$ARCH"
      - echo Build started on `date`
#      - aws s3 ls s3://maven.pocnettech.com
      - export creds=`curl 169.254.170.2$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI`
      - export AWS_ACCESS_KEY_ID=`echo $creds | jq -r .AccessKeyId`
      - export AWS_SECRET_ACCESS_KEY=`echo $creds | jq -r .SecretAccessKey`
      - export AWS_SESSION_TOKEN=`echo $creds | jq -r .Token`
      - echo "Building $PROJECTNAME Version $CODEBUILD_SOURCE_VERSION"
      - DOCKERHUB_USER=`echo $DOCKERHUB_CREDENTIALS|jq -r .username`
      - DOCKERHUB_TOKEN=`echo $DOCKERHUB_CREDENTIALS|jq -r .token`
      - echo $DOCKERHUB_TOKEN > pass.txt
      - cat pass.txt|docker login --username $DOCKERHUB_USER --password-stdin
      - env
      - docker build --build-arg "PAT=$PAT" --build-arg "BUILD_NUMBER=1.0.1" --build-arg "GITHUB_ACCESS_TOKEN=$GITHUB_ACCESS_TOKEN" --build-arg "GIT_BRANCH=$GIT_BRANCH" --build-arg "DOWNLOADLOCATION=$TOMCAT_DOWNLOAD_LOCATION" --build-arg "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" --build-arg "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" --build-arg "AWS_REGION=$AWS_DEFAULT_REGION" --build-arg "AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN" -t "$REPO_URL:$VERSION" .
      - $(aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION)
      - docker tag "$REPO_URL:$VERSION" $REPO_URL:latest
      - docker push "$REPO_URL:$VERSION"
${var.arm64Support?"#":""}      - docker push "$REPO_URL:latest"
  post_build:
    commands:
      - printf '[{"name":"main","imageUri":"%s"}]' "$REPO_URL:$VERSION" > taskdefinition.json
      - echo Build completed on `date`
artifacts:
  files: taskdefinition.json

DEFINITION
}

resource "aws_codebuild_project" "codebuildProject" {
  name         = "ecs-${var.name}"
  service_role = var.codebuildRoleArn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    privileged_mode = true
    environment_variable {
      name  = "DOCKERHUB_CREDENTIALS"
      value = var.dockerHubCredentials
      type  = "SECRETS_MANAGER"
    }
    environment_variable {
      name  = "GITHUB_ACCESS_TOKEN"
      value = var.githubAccessToken
      type  = "SECRETS_MANAGER"
    }
    environment_variable {
      name  = "PAT"
      value = var.NugetPat
      type  = "SECRETS_MANAGER"
    }

    environment_variable {
      name  = "REPO_URL"
      value = aws_ecr_repository.ecrRepo.repository_url
      type  = "PLAINTEXT"
    }
    environment_variable {
      name  = "TOMCAT_DOWNLOAD_LOCATION"
      value = var.tomcatDownloadLocation
    }
    dynamic "environment_variable" {
      for_each = var.buildVariables
      content {
        type  = environment_variable.value.type
        name  = environment_variable.value.name
        value = environment_variable.value.value
      }
    }
  }
  source {
    type            = "GITHUB"
    location        = var.gitURL
    git_clone_depth = 1
    buildspec       = var.useDefaultBuildSpec?local.defaultBuildSpec : "buildspec-new.yml"


    git_submodules_config {
      fetch_submodules = true
    }
  }
  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = var.logGroupName
      stream_name = var.name
    }
  }

}


resource "aws_codebuild_project" "codebuildProjectArm" {
  count        = var.arm64Support?1 : 0
  name         = "ecs-${var.name}-arm"
  service_role = var.codebuildRoleArn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "aws/codebuild/amazonlinux2-aarch64-standard:2.0"
    type                        = "ARM_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    privileged_mode = true
    environment_variable {
      name  = "DOCKERHUB_CREDENTIALS"
      value = var.dockerHubCredentials
      type  = "SECRETS_MANAGER"
    }
    environment_variable {
      name  = "GITHUB_ACCESS_TOKEN"
      value = var.githubAccessToken
      type  = "SECRETS_MANAGER"
    }
    environment_variable {
      name  = "PAT"
      value = var.NugetPat
      type  = "SECRETS_MANAGER"
    }
    environment_variable {
      name  = "REPO_URL"
      value = aws_ecr_repository.ecrRepo.repository_url
      type  = "PLAINTEXT"
    }
    environment_variable {
      name  = "TOMCAT_DOWNLOAD_LOCATION"
      value = var.tomcatDownloadLocation
    }
  }
  source {
    type            = "GITHUB"
    location        = var.gitURL
    git_clone_depth = 1
    buildspec       = var.useDefaultBuildSpec?local.defaultBuildSpec : "buildspec-new.yml"


    git_submodules_config {
      fetch_submodules = true
    }
  }
  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = var.logGroupName
      stream_name = var.name
    }
  }

}

resource "aws_codebuild_project" "codebuildProjectManifest" {
  count        = var.arm64Support?1 : 0
  name         = "ecs-${var.name}-manifest"
  service_role = var.codebuildRoleArn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_LARGE"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    privileged_mode = true
    environment_variable {
      name  = "DOCKERHUB_CREDENTIALS"
      value = var.dockerHubCredentials
      type  = "SECRETS_MANAGER"
    }
    environment_variable {
      name  = "REPO_URL"
      value = aws_ecr_repository.ecrRepo.repository_url
      type  = "PLAINTEXT"
    }
    environment_variable {
      name  = "TOMCAT_DOWNLOAD_LOCATION"
      value = var.tomcatDownloadLocation
    }
  }
  source {
    type            = "GITHUB"
    location        = var.gitURL
    git_clone_depth = 1
    buildspec       = <<DEFINITION
version: 0.2

phases:
  install:
    commands:
      - echo Logging in to Amazon ECR...
      - $(aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION)
  pre_build:
    commands:
      - echo pre-build phase...
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker manifest...
      - export DOCKER_CLI_EXPERIMENTAL=enabled
      - docker manifest create $REPO_URL:latest $REPO_URL:$COMMIT_ID-aarch64 $REPO_URL:$COMMIT_ID-x86_64
      - docker manifest annotate --arch arm64 $REPO_URL:latest $REPO_URL:$COMMIT_ID-aarch64
      - docker manifest annotate --arch amd64 $REPO_URL:latest $REPO_URL:$COMMIT_ID-x86_64
      - echo Pushing the Docker image...
      - docker manifest push $REPO_URL:latest
      - docker manifest inspect $REPO_URL:latest
      - echo Create Manifest with specific version
      - docker manifest create $REPO_URL:$COMMIT_ID $REPO_URL:$COMMIT_ID-aarch64 $REPO_URL:$COMMIT_ID-x86_64
      - docker manifest annotate --arch arm64 $REPO_URL:$COMMIT_ID $REPO_URL:$COMMIT_ID-aarch64
      - docker manifest annotate --arch amd64 $REPO_URL:$COMMIT_ID $REPO_URL:$COMMIT_ID-x86_64
      - echo Pushing the Docker image...
      - docker manifest push $REPO_URL:$COMMIT_ID
      - docker manifest inspect $REPO_URL:$COMMIT_ID
  post_build:
    commands:
      - printf '[{"name":"main","imageUri":"%s"}]' "$REPO_URL:$COMMIT_ID" > taskdefinition.json
      - echo Build completed on `date`
artifacts:
  files: taskdefinition.json

DEFINITION


    git_submodules_config {
      fetch_submodules = true
    }
  }
  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = var.logGroupName
      stream_name = var.name
    }
  }

}

output "codebuildRepositoryUrl" {
  value = aws_ecr_repository.ecrRepo.repository_url
}