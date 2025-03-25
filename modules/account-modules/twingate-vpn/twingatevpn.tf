variable "name" {
  description = "The name of the service"
  type        = string
}

variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

resource "aws_security_group" "ecs_service_sg" {
  name        = "${var.name}-ecs-service-sg"
  description = "Security group for ECS service with full egress access"
  vpc_id      = var.vpc_id

  # No inbound rules (default is to deny all inbound traffic)
  ingress = []

  # Full egress access (allow all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # All protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic to anywhere
  }

  tags = {
    Name = "${var.name}-ecs-service-sg"
  }
}
resource "aws_ecs_service" "service" {
  name            = var.name
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = false
  }

  depends_on = [aws_ecs_task_definition.service]
}
