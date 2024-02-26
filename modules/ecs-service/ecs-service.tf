variable "serviceName" {
  type        = string
  description = "ECS Service Name"
}
variable "clusterName" {
  type = string
}

variable "deploymentMaxPercent" {
  type    = number
  default = 200
}

variable "subNets" {
  type = list(string)
}
variable "healthCheckPort" {
  type = number
  default = -1
}

locals {
  nlbHealthCheck= var.healthCheckPort==-1? var.networkLoadBalancerAttachments.*.containerPort:var.healthCheckPort
}

variable "taskDefinitionFull" {}
variable "desiredCount" {
  type = number
}
data "aws_lb" "lb" {
  count = length(var.networkLoadBalancerAttachments)
  arn   = var.networkLoadBalancerAttachments[count.index].lbArn
}

resource "aws_ecs_service" "pwl-tcp-server-test-ecs-service" {
  name                       = var.serviceName
  cluster                    = var.clusterName
  deployment_maximum_percent = var.deploymentMaxPercent
  desired_count              = var.desiredCount

  dynamic "load_balancer" {
    for_each = aws_lb_target_group.nlbTargetGroup
    content {
      container_name   = var.networkLoadBalancerAttachments[load_balancer.key].containerName
      container_port   = var.networkLoadBalancerAttachments[load_balancer.key].containerPort
      target_group_arn = aws_lb_target_group.nlbTargetGroup[load_balancer.key].arn
    }
  }
  task_definition = var.taskDefinitionFull

  network_configuration {
    subnets         = var.subNets
    security_groups = [aws_security_group.serviceSg.id]
  }
  lifecycle {
    ignore_changes = [
      "capacity_provider_strategy"
    ]
  }
}

resource "aws_security_group" "serviceSg" {
  name   = var.serviceName
  vpc_id = var.vpc_id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

locals {
  containerPortsToBeOpen=distinct(concat(var.networkLoadBalancerAttachments.*.containerPort,local.nlbHealthCheck))
}

resource "aws_security_group_rule" "sgRules" {
  count             = length(local.containerPortsToBeOpen)
  from_port         = local.containerPortsToBeOpen[count.index]
  protocol          = "TCP"
  security_group_id = aws_security_group.serviceSg.id
  to_port           = local.containerPortsToBeOpen[count.index]
  type              = "ingress"
  cidr_blocks       = [data.aws_vpc.vpc.cidr_block]
  description       = "access from within vpc"
}



variable "networkLoadBalancerAttachments" {
  type = list(
    object({
    containerName = string
    containerPort = number
    protocol      = string
    lbArn         = string
    lbPort        = number
    certificateArn = optional(string)
    name=optional(string)
  }))
  default = [{
    containerName   = null
    containerPort   = null
    protocol        = null
    lbArn           = null
    lbPort          = null
    certificateArn  = null
    name            = null
  }]
}

variable "vpc_id" {

}


variable "ecs_service_protocol" {
  default = "TLS"
}
resource "aws_lb_listener" "nlbListeners" {
  count             = length(var.networkLoadBalancerAttachments)
  load_balancer_arn = var.networkLoadBalancerAttachments[count.index].lbArn
  port              = var.networkLoadBalancerAttachments[count.index].lbPort
  protocol          = var.networkLoadBalancerAttachments[count.index].protocol
  certificate_arn = lower(var.networkLoadBalancerAttachments[count.index].protocol)=="tcp"?null: var.networkLoadBalancerAttachments[count.index].certificateArn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlbTargetGroup[count.index].arn
  }
}

resource "aws_lb_target_group" "nlbTargetGroup" {
  count                = length(var.networkLoadBalancerAttachments)
  protocol             = var.ecs_service_protocol
  target_type          = "ip"
  name                 = var.networkLoadBalancerAttachments[count.index].name!=null ? "${var.serviceName}-${var.networkLoadBalancerAttachments[count.index].name}" : "${var.serviceName}-${var.networkLoadBalancerAttachments[count.index].containerName}-${var.networkLoadBalancerAttachments[count.index].containerPort}"
  deregistration_delay = 120
  port                 = var.networkLoadBalancerAttachments[count.index].containerPort
  //  load_balancing_algorithm_type = "least_outstanding_requests"
  slow_start           = 0
  dynamic "stickiness" {
    for_each = var.networkLoadBalancerAttachments[count.index].protocol=="TLS"?[] : [
      0
    ]
    content {
      type    = "source_ip"
      enabled = true
    }
  }
  health_check {
    protocol            = "TCP"
    port                = local.nlbHealthCheck
    healthy_threshold   = 5
    unhealthy_threshold = 5
    enabled             = true
  }
  vpc_id = var.vpc_id


}

output "securityGroupId" {
  value = aws_security_group.serviceSg.id
}
output "securityGroupArn" {
  value = aws_security_group.serviceSg.arn
}
output "securityGroupName" {
  value = aws_security_group.serviceSg.name
}
