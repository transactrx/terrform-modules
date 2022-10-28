variable "name" {
  type = string
}
variable "dockerHubCredSecretArn" {
  type = string
}
variable "gitHubTokenSecretArn" {
  type = string
}
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.name}-codepipeline-bucket"
}


module "policies" {
  source                = "../cdspipeline/policies"
  name                  = "${var.name}-codepiplinePolicy"
  codebuildSecrets      = [var.dockerHubCredSecretArn, var.gitHubTokenSecretArn]
  codepipelineBucketArn = aws_s3_bucket.codepipeline_bucket.arn
}

module "codepipelineRole" {
  source           = "../cdspipeline/roles"
  name             = "codepipelineRole-${var.name}"
  attachedPolicies = [module.policies.codepipelinePolicyArn]
  servicePrinciple = "codepipeline.amazonaws.com"

}

module "codebuildRole" {
  source           = "../cdspipeline/roles"
  name             = "${var.name}-codebuildRole"
  attachedPolicies = [module.policies.codebuildPolicyArn]
  servicePrinciple = "codebuild.amazonaws.com"

}

output "codeBuildRoleArn" {
  value = module.codebuildRole.roleArn
}
output "codeBuildRoleName" {
  value = module.codebuildRole.roleName
}

output "codePipelineRoleArn" {
  value = module.codepipelineRole.roleArn
}
output "codePipelineRoleName" {
  value = module.codepipelineRole.roleName
}

output "codePipeLineS3Arn" {
  value = aws_s3_bucket.codepipeline_bucket.arn
}
output "codePipelineS3Bucket" {
  value = aws_s3_bucket.codepipeline_bucket.bucket
}