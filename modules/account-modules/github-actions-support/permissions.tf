data "aws_iam_policy_document" "allow_ecr_actions" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "ecr:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "allow_ecr_actions" {
  name   = "allow_ecr_actions"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.allow_ecr_actions.json
}

data "aws_iam_policy_document" "allow_ecs_actions" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "ecs:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "allow_ecs_actions" {
  name   = "allow_ecs_actions"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.allow_ecs_actions.json
}

data "aws_iam_policy_document" "allow_ecs_autoscaling_config" {
  statement {
    effect = "Allow"
    actions = [
      "application-autoscaling:*",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:SetAlarmState"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "allow_autoscaling_config" {
  name   = "allow_autoscaling_config"
  policy = data.aws_iam_policy_document.allow_ecs_autoscaling_config.json
  role   = aws_iam_role.github_actions.name
}

data "aws_iam_policy_document" "allow_ssm_params_actions" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "ssm:Get*",
      "ssm:Desc*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "allow_ssm_params_actions" {
  name   = "allow_ssm_actions"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.allow_ssm_params_actions.json
}

data "aws_iam_policy_document" "allow_ec2_actions" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "ec2:Get*",
      "ec2:Desc*",
      "ec2:*Tags",
      "ec2:*VpcEndpoint",
      "ec2:*SecurityGroup",
      "ec2:*SecurityGroup*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "allow_ec2_actions" {
  name   = "allow_ec2_actions"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.allow_ec2_actions.json
}

data "aws_iam_policy_document" "allow_cloudwatch_logs_actions" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "logs:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "allow_cloudwatch_actions" {
  name   = "allow_cloudwatch_logs_actions"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.allow_cloudwatch_logs_actions.json
}

data "aws_iam_policy_document" "allow-full-s3-permissions" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "allow_full_s3_permissions" {
  name   = "allow_full_s3_bucket_actions"
  policy = data.aws_iam_policy_document.allow-full-s3-permissions.json
  role   = aws_iam_role.github_actions.name
}

data "aws_iam_policy_document" "allow-full-aws-batch-permissions" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "batch:*",
    ]
    resources = ["*"]
  }

}
resource "aws_iam_role_policy" "allow-full-aws-batch-permissions" {
  name   = "allow_full_aws_batch_actions"
  policy = data.aws_iam_policy_document.allow-full-aws-batch-permissions.json
  role   = aws_iam_role.github_actions.name
}

data "aws_iam_policy_document" "allow-iam-role-creation" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:CreateRole",
      "iam:GetRolePolicy",
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:DeleteRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:PassRole",
      "iam:CreateServiceLinkedRole"
    ]
    resources = ["*"]
  }

}
resource "aws_iam_role_policy" "allow-iam-role-creation" {
  name   = "allow_iam_role_creation"
  policy = data.aws_iam_policy_document.allow-iam-role-creation.json
  role   = aws_iam_role.github_actions.name
}


data "aws_iam_policy_document" "allow-secret-creation" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:*"
    ]
    resources = ["*"]
  }

}
resource "aws_iam_role_policy" "allow-secret-creation" {
  name   = "allow-secret-creation"
  policy = data.aws_iam_policy_document.allow-secret-creation.json
  role   = aws_iam_role.github_actions.name
}

//allows attaching ecs services to nlbs

data "aws_iam_policy_document" "allow-nlb-attachment" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:*",
      "ecs:UpdateService",
      "ecs:DescribeServices"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "allow-nlb-attachment" {
  name   = "allow-nlb-attachment"
  policy = data.aws_iam_policy_document.allow-nlb-attachment.json
  role   = aws_iam_role.github_actions.name
}

data "aws_iam_policy_document" "allow_route53_record_changes" {
  version = "2012-10-17"
  statement {
    effect    = "Allow"
    actions   = ["route53:*"]
    resources = ["arn:aws:route53:::*"]
  }
}

resource "aws_iam_role_policy" "allow-route53-name-management" {
  name   = "allow-route53-name-management"
  policy = data.aws_iam_policy_document.allow_route53_record_changes.json
  role   = aws_iam_role.github_actions.name
}

//give github access to SNS and SES

data "aws_iam_policy_document" "allow-full-ses-permissions" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "ses:*",
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "allow_full_ses_permissions" {
  name   = "allow_full_ses_actions"
  policy = data.aws_iam_policy_document.allow-full-ses-permissions.json
  role   = aws_iam_role.github_actions.name
}


data "aws_iam_policy_document" "allow-full-sns-permissions" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "sns:*",
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "allow_full_sns_permissions" {
  name   = "allow_full_sns_actions"
  policy = data.aws_iam_policy_document.allow-full-sns-permissions.json
  role   = aws_iam_role.github_actions.name
}

//give github access to cloudfront
data "aws_iam_policy_document" "allow-cloudfront-permissions" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "cloudfront:*",
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "allow-cloudfront-permissions" {
  name   = "allow-cloudfront-permissions"
  policy = data.aws_iam_policy_document.allow-cloudfront-permissions.json
  role   = aws_iam_role.github_actions.name
}

data "aws_iam_policy_document" "allow-waf-permissions" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "wafv2:*",
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "allow-waf-permissions" {
  name   = "allow-waf-permissions"
  policy = data.aws_iam_policy_document.allow-waf-permissions.json
  role   = aws_iam_role.github_actions.name
}

data "aws_iam_policy_document" "allow-route53-permissions" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "route53:*",
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "allow-route53-permissions" {
  name   = "allow-route53-permissions"
  policy = data.aws_iam_policy_document.allow-route53-permissions.json
  role   = aws_iam_role.github_actions.name
}

data "aws_iam_policy_document" "allow-cognito-permissions" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      # User pool management
      "cognito-idp:CreateUserPool",
      "cognito-idp:DeleteUserPool",
      "cognito-idp:UpdateUserPool",
      "cognito-idp:DescribeUserPool",
      "cognito-idp:ListUserPools",
      "cognito-idp:GetUserPoolMfaConfig",

      # User pool client
      "cognito-idp:CreateUserPoolClient",
      "cognito-idp:DeleteUserPoolClient",
      "cognito-idp:UpdateUserPoolClient",
      "cognito-idp:DescribeUserPoolClient",

      # Identity provider (e.g. SAML or OIDC)
      "cognito-idp:CreateIdentityProvider",
      "cognito-idp:UpdateIdentityProvider",
      "cognito-idp:DeleteIdentityProvider",
      "cognito-idp:DescribeIdentityProvider",

      # User pool domain
      "cognito-idp:CreateUserPoolDomain",
      "cognito-idp:DeleteUserPoolDomain",
      "cognito-idp:DescribeUserPoolDomain"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "allow-cognito-permissions" {
  name   = "allow-cognito-permissions"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.allow-cognito-permissions.json
}

data "aws_iam_policy_document" "allow-dsql-creation" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "dsql:*"
    ]
    resources = ["*"]
  }

}
resource "aws_iam_role_policy" "allow-dsql-creation" {
  name   = "allow-dsql-creation"
  policy = data.aws_iam_policy_document.allow-dsql-creation.json
  role   = aws_iam_role.github_actions.name
}


data "aws_iam_policy_document" "allow-backup" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "backup:*"
    ]
    resources = ["*"]
  }

}
resource "aws_iam_role_policy" "allow-backup" {
  name   = "allow-backup"
  policy = data.aws_iam_policy_document.allow-backup.json
  role   = aws_iam_role.github_actions.name
}


data "aws_iam_policy_document" "allow-KMS" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }

}
resource "aws_iam_role_policy" "allow-KMS" {
  name   = "allow-kms"
  policy = data.aws_iam_policy_document.allow-KMS.json
  role   = aws_iam_role.github_actions.name
}

data "aws_iam_policy_document" "allow-backup-storage" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "backup-storage:*"
    ]
    resources = ["*"]
  }

}
resource "aws_iam_role_policy" "allow-backup-storage" {
  name   = "allow-backup-storage"
  policy = data.aws_iam_policy_document.allow-backup-storage.json
  role   = aws_iam_role.github_actions.name
}


data "aws_iam_policy_document" "allow-ssm" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "ssm:*"
    ]
    resources = ["*"]
  }

}
resource "aws_iam_role_policy" "allow-ssm" {
  name   = "allow-ssm"
  policy = data.aws_iam_policy_document.allow-ssm.json
  role   = aws_iam_role.github_actions.name
}


data "aws_iam_policy_document" "allow-lambda-invoke" {
  version = "2012-10-17"

  statement {
    sid     = "AllowInvokeAlbSequenceLambdasAllEnv"
    effect  = "Allow"
    actions = [
      "lambda:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "allow-lambda-invoke" {
  name   = "allow-lambda-invoke"
  policy = data.aws_iam_policy_document.allow-lambda-invoke.json
  role   = aws_iam_role.github_actions.name
}


data "aws_iam_policy_document" "allow_codestar_connection_use" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "codestar-connections:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "allow_codestar_connection_use" {
  name   = "allow_codestar_connection_use"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.allow_codestar_connection_use.json
}


# IAM Policy Document for Global Accelerator permissions
data "aws_iam_policy_document" "allow_globalaccelerator_permissions" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "globalaccelerator:*"
    ]
    resources = ["*"]
  }
}

# IAM Role Policy for Global Accelerator (if you need to attach to a role)
resource "aws_iam_role_policy" "allow_globalaccelerator_permissions" {
  name   = "allow-globalaccelerator-permissions"
  policy = data.aws_iam_policy_document.allow_globalaccelerator_permissions.json
  role   = aws_iam_role.github_actions.name  # Replace with your role name
}

data "aws_iam_policy_document" "allow_sqs_actions" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "sqs:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "allow_sqs_actions" {
  name   = "allow_sqs_actions"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.allow_sqs_actions.json
}


data "aws_iam_policy_document" "allow_eventbridge_scheduler" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "scheduler:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "allow_eventbridge_scheduler" {
  name   = "allow_eventbridge_scheduler"
  role   = aws_iam_role.github_actions.name
  policy = data.aws_iam_policy_document.allow_eventbridge_scheduler.json
}