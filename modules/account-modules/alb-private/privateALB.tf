variable "vpcId" {
  type = string
}
variable "albName" {
  type = string
}

variable "privateZoneId" {}

variable "privateSubnets" {
  type = list(string)
}

variable "publicCertificate" {
  type = string
}

variable "additionalCerts" {
  type    = set(string)
  default = []
}
variable "publicDomain" {
  type = string
}
variable "publicDomainNaked" {
  type = string
}
variable "corpDomain" {
  type = string
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
  name = var.publicDomain
  type = "CNAME"
  zone_id = var.privateZoneId
  ttl     = "300"
  records = [aws_lb.alb.dns_name]
}

resource "aws_lb" "alb" {
  name               = var.albName
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALBSecurityGroup.id]
  subnets            = var.privateSubnets
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
      host = "www.${var.corpDomain}"
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
      host = "www.${var.publicDomainNaked}"
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

# Strip empties and normalize to a set(string)
locals {
  normalized_additional = toset([
    for s in var.additionalCerts : trim(s)
    if trim(s) != ""
  ])

  # Remove the primary if it accidentally appears in the additional list
  sni_certs = setsubtract(
    local.normalized_additional,
    toset([var.publicCertificate])
  )
}

# Attach all extra/SNI certs
resource "aws_lb_listener_certificate" "additionalCerts" {
  for_each        = local.sni_certs
  listener_arn    = aws_alb_listener.defaultListener.arn
  certificate_arn = each.key   # (each.key == each.value for sets)
}

output "privateSubnets" {
  value = var.privateSubnets
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