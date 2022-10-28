variable "name" {
  type = string
}
variable "codebuildSecrets" {
  type = list(string)
}
variable "codepipelineBucketArn" {}

resource "aws_iam_policy" "codebuildPolicy" {
  policy = <<EOF
{
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "ecrAuthToken",
                    "Effect": "Allow",
                    "Action": "ecr:GetAuthorizationToken",
                    "Resource": "*"
                },
                {
                    "Sid": "ecrAccess",
                    "Effect": "Allow",
                    "Action": "ecr:*",
                    "Resource": "arn:aws:ecr:*:*:repository/*"
                },
                {
                  "Effect": "Allow",
                  "Resource": [
                    "*"
                  ],
                  "Action": [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                  ]
                },
                {
                    "Action": [
                        "s3:PutObject",
                        "s3:GetObject",
                        "s3:GetObjectVersion",
                        "s3:GetBucketAcl",
                        "s3:GetBucketLocation"
                    ],
                    "Resource": [
                        "arn:aws:s3:::codepipeline-us-east-1-*"
                    ],
                    "Effect": "Allow"
                },
                {
                    "Action": "s3:*",
                    "Resource": [
                        "arn:aws:s3:::maven.pocnettech.com",
                        "arn:aws:s3:::maven.pocnettech.com/*"
                    ],
                    "Effect": "Allow",
                    "Sid": "mavenaccess"
                },
                {
                    "Action": [
                        "codebuild:CreateReportGroup",
                        "codebuild:CreateReport",
                        "codebuild:UpdateReport",
                        "codebuild:BatchPutTestCases"
                    ],
                    "Resource": [
                        "arn:aws:codebuild:::report-group/*"
                    ],
                    "Effect": "Allow"
                },
                {
                      "Sid": "VisualEditor0",
                      "Effect": "Allow",
                      "Action": [
                          "secretsmanager:GetRandomPassword",
                          "secretsmanager:GetResourcePolicy",
                          "secretsmanager:GetSecretValue",
                          "secretsmanager:DescribeSecret",
                          "secretsmanager:ListSecretVersionIds"
                      ],
                      "Resource": ["*"]
                },
                {
                    "Effect":"Allow",
                    "Action": [
                      "s3:GetObject",
                      "s3:GetObjectVersion",
                      "s3:GetBucketVersioning",
                      "s3:PutObject"
                    ],
                    "Resource": [
                      "${var.codepipelineBucketArn}",
                      "${var.codepipelineBucketArn}/*"
                    ]
              }
            ]
        }
  EOF
  name   = join("-", [var.name, "codebuild-policy"])
}

resource "aws_iam_policy" "codepipelinePolicy" {
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "cloudformation.amazonaws.com",
                        "elasticbeanstalk.amazonaws.com",
                        "ec2.amazonaws.com",
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            },
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplication",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codestar-connections:UseConnection"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "elasticbeanstalk:*",
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "s3:*",
                "sns:*",
                "cloudformation:*",
                "rds:*",
                "sqs:*",
                "ecs:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "lambda:InvokeFunction",
                "lambda:ListFunctions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "opsworks:CreateDeployment",
                "opsworks:DescribeApps",
                "opsworks:DescribeCommands",
                "opsworks:DescribeDeployments",
                "opsworks:DescribeInstances",
                "opsworks:DescribeStacks",
                "opsworks:UpdateApp",
                "opsworks:UpdateStack"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks",
                "cloudformation:UpdateStack",
                "cloudformation:CreateChangeSet",
                "cloudformation:DeleteChangeSet",
                "cloudformation:DescribeChangeSet",
                "cloudformation:ExecuteChangeSet",
                "cloudformation:SetStackPolicy",
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "devicefarm:ListProjects",
                "devicefarm:ListDevicePools",
                "devicefarm:GetRun",
                "devicefarm:GetUpload",
                "devicefarm:CreateUpload",
                "devicefarm:ScheduleRun"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "servicecatalog:ListProvisioningArtifacts",
                "servicecatalog:CreateProvisioningArtifact",
                "servicecatalog:DescribeProvisioningArtifact",
                "servicecatalog:DeleteProvisioningArtifact",
                "servicecatalog:UpdateProduct"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ecr:DescribeImages"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
              "Effect":"Allow",
              "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketVersioning",
                "s3:PutObject"
              ],
              "Resource": [
                "${var.codepipelineBucketArn}",
                "${var.codepipelineBucketArn}/*"
              ]
            }
    ]
}

  EOF
  name   = join("-", [var.name, "codepipeline-policy"])
}


output "codebuildPolicyArn" {
  value = aws_iam_policy.codebuildPolicy.arn
}
output "codebuildPolicyId" {
  value = aws_iam_policy.codebuildPolicy.id
}

output "codepipelinePolicyArn" {
  value = aws_iam_policy.codepipelinePolicy.arn
}
output "codepipelinePolicyId" {
  value = aws_iam_policy.codepipelinePolicy.id
}
