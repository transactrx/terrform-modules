
# Extra CIDRs that need to reach PostgreSQL from outside this VPC, typically
# another account reached over the shared transit gateway. The canonical case is
# the AWS Batch account VPC (10.105.0.0/16 dev, 10.106.0.0/16 prod), whose
# scheduled jobs read application databases directly. Defaults to empty, so
# existing consumers keep a VPC-only ingress rule.
variable "additional_ingress_cidrs" {
  description = "CIDRs allowed to reach PostgreSQL on 5432 in addition to the VPC CIDR."
  type        = list(string)
  default     = []
}

resource "aws_security_group" "aurora_sg" {
  name        = var.name
  description = "Allow inbound access to Aurora PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432 # PostgreSQL default port
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = concat([var.vpc_cidr], var.additional_ingress_cidrs) # The VPC, plus any explicitly allowed cross-account CIDRs
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
