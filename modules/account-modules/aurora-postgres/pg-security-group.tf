
resource "aws_security_group" "aurora_sg" {
  name        = var.name
  description = "Allow inbound access to Aurora PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432 # PostgreSQL default port
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # Allow access from within the VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }
}
