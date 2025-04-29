variable "branch_name" {
  type = string
}
resource "aws_iam_openid_connect_provider" "githubIdentityProvider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
  url             = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.githubIdentityProvider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:transactrx/*:${var.branch_name}*"
      ]
    }
  }
}

resource "aws_s3_bucket" "terraformBucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.name}-github-terraform-state"

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

resource "aws_s3_bucket_versioning" "terraformBucketVersioning" {
  bucket = aws_s3_bucket.terraformBucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraformLockTable" {
  name           = "${var.name}-github-actions-terraform-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    "Name" = "${var.name} - DynamoDB Terraform State Lock Table"
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
  name        = "${var.name}-terraform-lock-policy"
  path        = "/"
  description = "Policy for locking terraform state in dynamodb"
  policy      = data.aws_iam_policy_document.terraformLockPolicyDoc.json
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
  name        = "${var.name}-terraform-s3-policy"
  path        = "/"
  description = "Policy for allowing terraform to write state files to s3"
  policy      = data.aws_iam_policy_document.terraformS3PolicyDoc.json
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.name}-github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}
resource "aws_iam_role_policy_attachment" "attach_terraform_lock_policy" {
  policy_arn = aws_iam_policy.terraformLockPolicy.arn
  role       = aws_iam_role.github_actions.name
}
resource "aws_iam_role_policy_attachment" "attach_terraform_s3_policy" {
  policy_arn = aws_iam_policy.terraformS3Policy.arn
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
