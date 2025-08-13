locals {
  name_prefix = var.region != "" ? "${var.name}-${var.region}" : var.name
}

data "aws_caller_identity" "current" {
}

resource "aws_s3_bucket" "terraformBucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-${local.name_prefix}-github-terraform-state"
}

resource "aws_s3_bucket_versioning" "terraformBucketVersioning" {
  bucket = aws_s3_bucket.terraformBucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "terraformBucketOwnershipControls" {
  bucket = aws_s3_bucket.terraformBucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "terraformBucketACL" {
  depends_on = [aws_s3_bucket_ownership_controls.terraformBucketOwnershipControls]
  bucket     = aws_s3_bucket.terraformBucket.id
  acl        = "private"
}

data "aws_iam_policy_document" "terraformS3PolicyDoc" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    effect    = "Allow"
    resources = [aws_s3_bucket.terraformBucket.arn, "${aws_s3_bucket.terraformBucket.arn}/*"]
  }
}

resource "aws_iam_policy" "terraformS3Policy" {
  name        = "${local.name_prefix}-terraform-s3-policy"
  path        = "/"
  description = "Policy for allowing terraform to write state files to s3"
  policy      = data.aws_iam_policy_document.terraformS3PolicyDoc.json
}

resource "aws_iam_role_policy_attachment" "attach_terraform_s3_policy" {
  policy_arn = aws_iam_policy.terraformS3Policy.arn
  role       = aws_iam_role.github_actions.name
}

resource "aws_dynamodb_table" "terraformLockTable" {
  name           = "${local.name_prefix}-github-actions-terraform-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    "Name" = "${local.name_prefix} - DynamoDB Terraform State Lock Table"
  }
}

data "aws_iam_policy_document" "terraformLockPolicyDoc" {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    effect    = "Allow"
    resources = [aws_dynamodb_table.terraformLockTable.arn]
  }
}

resource "aws_iam_policy" "terraformLockPolicy" {
  name        = "${local.name_prefix}-terraform-lock-policy"
  path        = "/"
  description = "Policy for locking terraform state in dynamodb"
  policy      = data.aws_iam_policy_document.terraformLockPolicyDoc.json
}

resource "aws_iam_role_policy_attachment" "attach_terraform_lock_policy" {
  policy_arn = aws_iam_policy.terraformLockPolicy.arn
  role       = aws_iam_role.github_actions.name
}

resource "aws_ssm_parameter" "terraform_state_bucket_name" {
  name  = "terraform_state_bucket_name"
  type  = "String"
  value = aws_s3_bucket.terraformBucket.bucket
}

resource "aws_ssm_parameter" "terraform_lock_table_name" {
  name  = "terraform_lock_table"
  type  = "String"
  value = aws_dynamodb_table.terraformLockTable.name
}
