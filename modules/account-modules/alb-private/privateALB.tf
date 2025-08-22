variable "vpcId" {
  type = string
}
variable "albName" {
  type = string
}

variable "envObject" {}
variable "privateZoneId" {}

variable "privateSubnets" {
  type = list(string)
}

variable "publicCertificate" {
  type = string
}
variable "publicCertificate2" {
  type = string
}
variable "publicCertificate3" {
  type = string
}
variable "publicCertificate4" {
  type = string
}
variable "additionalCerts" {
  default = []
  type = list(string)
}

resource "aws_security_group" "ALBSecurityGroup" {
  name = var.albName
  description = "Security for the private Load Balancer"
  vpc_id = var.vpcId
  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "tcp"
    to_port = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_record" "privateHostRecord" {
  name = split(",",var.envObject.publicDomain)[0]
  type = "CNAME"
  zone_id = var.privateZoneId
  ttl     = "300"
  records = [aws_lb.alb.dns_name]
}

locals {
  privateSubnets=split(",",var.privateSubnets)
}

resource "aws_lb" "alb" {
  name               = var.albName
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALBSecurityGroup.id]
  subnets            = local.privateSubnets
  idle_timeout = 600
  enable_deletion_protection = true
  tags = {
    source = "terraform"
  }
}

resource "aws_alb_listener" "defaultListener" {
  load_balancer_arn = aws_lb.alb.arn
  port = 443
  protocol = "HTTPS"
  certificate_arn = var.publicCertificate
  ssl_policy = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Oops! This page does not exist"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "redirectToEnrollment" {
  listener_arn = aws_alb_listener.defaultListener.arn
  priority = 410
  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      host = "www.${var.envObject.corpDomain}"
      path = "/enrollment"
      status_code = "HTTP_301"
      query = ""
    }
  }
  condition {
    host_header {
      values = ["enroll.mytransactrx.com"]
    }
  }
}

resource "aws_lb_listener_rule" "redirectToOldUrl" {
  listener_arn = aws_alb_listener.defaultListener.arn
  priority = 420
  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      host = "www.${var.envObject.publicDomainNaked}"
      path = "/"
      status_code = "HTTP_301"
      query = ""
    }
  }
  condition {
    host_header {
      values = ["www.mytransactrx.com"]
    }
  }
}

resource "aws_lb_listener_certificate" "cert2" {
  certificate_arn = var.publicCertificate2
  listener_arn = aws_alb_listener.defaultListener.arn
}
resource "aws_lb_listener_certificate" "cert3" {
  certificate_arn = var.publicCertificate3
  listener_arn = aws_alb_listener.defaultListener.arn
}
resource "aws_lb_listener_certificate" "cert4" {
  certificate_arn = var.publicCertificate4
  listener_arn = aws_alb_listener.defaultListener.arn
}

resource "aws_lb_listener_certificate" "additionalCerts" {
  count = length(var.additionalCerts)
  certificate_arn = var.additionalCerts[count.index]
  listener_arn = aws_alb_listener.defaultListener.arn
}

output "privateSubnets" {
  value = local.privateSubnets
}
output "loadBalancerArn" {
  value = aws_lb.alb.arn
}
output "defaultListenerArn" {
  value = aws_alb_listener.defaultListener.arn
}
output "securityGroupId" {
  value = aws_security_group.ALBSecurityGroup.id
}
output "dns" {
  value = aws_lb.alb.dns_name
}