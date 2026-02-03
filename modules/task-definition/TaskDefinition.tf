variable "ContainerList" {
}

variable "Os" {
  type    = string
  default = "LINUX"
}

variable "CPU_Arch" {
  type    = string
  default = "X86_64"
}

variable "CPU" {
  type = number
}

variable "Memory" {
  type = number
}

variable "taskDefFamily" {}

variable "mainImageURL" {
  type = string
}

variable "addExtraFargateStorage" {
  type    = bool
  default = false
}

variable "ecs_execution_role_name" {
  description = "Override for ECS Task Execution Role name"
  type        = string
  default     = null
}

variable "ecs_task_role_name" {
  description = "Override for ECS Task Execution Role name"
  type        = string
  default     = null
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_execution_role_name != null ? var.ecs_execution_role_name : "${var.taskDefFamily}-ecs-execution-role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name               = var.ecs_task_role_name != null ? var.ecs_task_role_name : "${var.taskDefFamily}-ecs-task-role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   },
   {
     "Effect": "Allow",
     "Action": [
       "ssmmessages:CreateControlChannel",
       "ssmmessages:CreateDataChannel",
       "ssmmessages:OpenControlChannel",
       "ssmmessages:OpenDataChannel"
     ],
     "Resource": "*"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy" "secretsAccess" {
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "ecr"
        },
        {
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "arn:aws:secretsmanager:*:*:secret:*",
            "Effect": "Allow",
            "Sid": "secretsmanager"
        },
        {
            "Action": [
                "ssm:GetParameterHistory",
                "ssm:GetParametersByPath",
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "ssmparameters"
        }
    ]
}
EOF
  role   = aws_iam_role.ecs_task_execution_role.name
}

resource "aws_ecs_task_definition" "test" {
  family                   = var.taskDefFamily
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.CPU
  memory                   = var.Memory
  container_definitions    = replace(jsonencode(var.ContainerList), "$$MAIN_IMAGE$$", var.mainImageURL)
  runtime_platform {
    operating_system_family = var.Os
    cpu_architecture        = var.CPU_Arch
  }
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  skip_destroy = true

  dynamic "ephemeral_storage" {
    for_each = var.addExtraFargateStorage ? [1] : []
    content {
      size_in_gib = 200
    }
  }
}


output "taskDefArn" {
  value = aws_ecs_task_definition.test.arn
}

output "task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "task_role_name" {
  value = aws_iam_role.ecs_task_role.name
}

output "execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "execution_role_name" {
  value = aws_iam_role.ecs_task_execution_role.name
}

output "task_definition_full_path" {
  value = "${aws_ecs_task_definition.test.family}:${aws_ecs_task_definition.test.revision}"
}
