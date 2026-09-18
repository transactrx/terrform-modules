variable "vpc_id" {
  type = string
}
variable "name" {
  type = string
}

variable "domain_suffix" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "public_subnetIds" {
  type = any
}

variable "certificate_arn" {
  type = string
}
variable "additional_certificate_arns" {
  type = list(string)
}

# Default action for the :443 listener, returned when no listener rule matches.
# The defaults reproduce this module's previous hardcoded response, so existing
# consumers plan clean; override them to serve a friendlier page instead.
variable "default_response_content_type" {
  description = "Content type of the :443 listener's default fixed response."
  type        = string
  default     = "text/plain"
}

variable "default_response_body" {
  description = "Body of the :443 listener's default fixed response."
  type        = string
  default     = "Forbidden"
}

variable "default_response_status_code" {
  description = "HTTP status code of the :443 listener's default fixed response."
  type        = string
  default     = "403"
}


resource "aws_security_group" "sg" {
  name   = "${var.name}-sg"
  vpc_id = var.vpc_id
  tags = {
    source = "terraform"
  }
}

resource "aws_lb" "alb" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = var.public_subnetIds

  enable_deletion_protection = false
  tags = {
    source = "terraform"
  }
}



resource "aws_lb_listener" "defaultListener80" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  lifecycle {
    ignore_changes = [load_balancer_arn, port]
  }
}

resource "aws_lb_listener" "defaultListener443" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = var.default_response_content_type
      message_body = var.default_response_body
      status_code  = var.default_response_status_code
    }
  }
  lifecycle {
    ignore_changes = [load_balancer_arn, port]
  }
}

resource "aws_lb_listener_certificate" "defaultListener443" {
  count           = length(var.additional_certificate_arns)
  listener_arn    = aws_lb_listener.defaultListener443.arn
  certificate_arn = var.additional_certificate_arns[count.index]
  depends_on      = [aws_lb_listener.defaultListener443]
}




