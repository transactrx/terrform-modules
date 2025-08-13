resource "aws_iam_openid_connect_provider" "githubIdentityProvider" {
  count             = var.identity_provider_arn == null ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
  url             = "https://token.actions.githubusercontent.com"
}

locals {
  identity_provider_arn = var.identity_provider_arn != null ? var.identity_provider_arn : aws_iam_openid_connect_provider.githubIdentityProvider[0].arn
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

resource "aws_iam_role" "github_actions" {
  name               = "${var.name}-github-actions${var.region != "" ? "-${var.region}" : ""}"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}