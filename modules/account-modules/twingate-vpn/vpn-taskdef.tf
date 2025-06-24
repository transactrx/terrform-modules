data "aws_region" "current" {}
resource "aws_ecs_task_definition" "service" {
  family = var.name
  container_definitions = jsonencode([
    {
      name      = var.name
      image     = "twingate/connector:1"
      cpu       = 512
      memory    = 512
      essential = true

      environment = [
        {
          name  = "TWINGATE_NETWORK"
          value = "redsailtechnologies"
        }
      ]

      secrets = [
        {
          name      = "TWINGATE_ACCESS_TOKEN"
          valueFrom = "${aws_secretsmanager_secret.twingate_secrets.arn}:token::"
        },
        {
          name      = "TWINGATE_REFRESH_TOKEN"
          valueFrom = "${aws_secretsmanager_secret.twingate_secrets.arn}:refresh::"
        }

      ]

      # CloudWatch Logging Configuration
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.name}" # CloudWatch Logs group name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs" # Prefix for the log streams
        }
      }
    }
  ])

  # Add the Task Role and Task Execution Role
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  # Required for Fargate launch type
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 2048
}

resource "aws_secretsmanager_secret" "twingate_secrets" {
  name        = "twingate-access-tokens"
  description = "twingate_access_tokens"

  tags = {
    Name = "TwinGate VPN tokens"
  }
}

resource "aws_secretsmanager_secret_version" "twingate_default_secrets" {
  secret_id = aws_secretsmanager_secret.twingate_secrets.id
  secret_string = jsonencode({
    token   = "change-me"
    refresh = "change-me"
  })
  lifecycle {
    ignore_changes = [secret_string,
        version_id,
        version_stages]
  }
}
