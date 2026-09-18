# State migration for consumers of the vendored copy of this module
# (rasdataservices_aws resources/us-west-2/modules/github-actions-support),
# which renamed these resources to snake_case. The moved blocks map the
# vendored addresses back to this module's addresses so switching the module
# source back to this shared module is a pure rename — no destroy/recreate of
# the Terraform state bucket, lock table, or IAM resources.
#
# For consumers that always used this module, none of the "from" addresses
# exist in state, so every block is a no-op.

moved {
  from = aws_s3_bucket.terraform_bucket
  to   = aws_s3_bucket.terraformBucket
}

moved {
  from = aws_s3_bucket_versioning.terraform_bucket_versioning
  to   = aws_s3_bucket_versioning.terraformBucketVersioning
}

moved {
  from = aws_s3_bucket_ownership_controls.terraform_bucket_ownership
  to   = aws_s3_bucket_ownership_controls.terraformBucketOwnershipControls
}

moved {
  from = aws_s3_bucket_acl.terraform_bucket_acl
  to   = aws_s3_bucket_acl.terraformBucketACL
}

moved {
  from = aws_dynamodb_table.terraform_lock_table
  to   = aws_dynamodb_table.terraformLockTable
}

moved {
  from = aws_iam_policy.terraform_s3_policy
  to   = aws_iam_policy.terraformS3Policy
}

moved {
  from = aws_iam_policy.terraform_lock_policy
  to   = aws_iam_policy.terraformLockPolicy
}

moved {
  from = aws_ssm_parameter.private_subnet_ids
  to   = aws_ssm_parameter.private-subnet-ids
}

moved {
  from = aws_ssm_parameter.vpc_id
  to   = aws_ssm_parameter.vpc-id
}

moved {
  from = aws_iam_openid_connect_provider.github_identity_provider
  to   = aws_iam_openid_connect_provider.githubIdentityProvider
}

# 27d450b put the OIDC provider behind `count` so a second region can reuse the
# first one's provider. That moved its state address from the bare name to [0].
# Accounts that have applied since then are already at [0], so this block is a
# no-op for them. A consumer arriving from an older vendored copy still holds
# the un-indexed address, and without this move Terraform destroys and recreates
# the account's GitHub OIDC provider -- which breaks every Actions deploy into
# that account for the length of the apply.
moved {
  from = aws_iam_openid_connect_provider.githubIdentityProvider
  to   = aws_iam_openid_connect_provider.githubIdentityProvider[0]
}
