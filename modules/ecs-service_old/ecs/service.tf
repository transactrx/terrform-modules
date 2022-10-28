variable "serviceName" {}
variable "cluster" {}
variable "healthCheckPath" {}
variable "listenerArn" {}
variable "listenerPriority" {
  type = number
}
variable "albSgId" {}
variable "desiredCount" {
  type = number
}
variable "listenerPath" {
  type = list(string)
}
variable "listenerHosts" {
  type    = list(string)
  default = []
}
variable "nlb" {
  default = false
}
variable "nlbPorts" {
  default = []
  type    = list(object({
    servicePort   = number
    protocol      = string
    nlbPort       = number
    containerName = string
  }))
}
variable "nlbHealthCheckPort" {
  default = 0
  type    = number
}

variable "connectToLB" {
  default = true
  type    = bool
}
variable "networkLbCertificateArn" {
  default = null
}

variable "scheduleCron" {
  default = ""
  type    = string
}


data "aws_cloudformation_export" "vpcId" {
  name = "Env-VpcId"
}

data "aws_cloudformation_export" "privateSubnets" {
  name = "Env-privateSubnets"
}

resource "aws_security_group" "sg" {
  count  = var.nlb ? 0 : 1
  //only non-nlb
  vpc_id = data.aws_cloudformation_export.vpcId.value
  ingress {
    from_port       = 443
    protocol        = "tcp"
    to_port         = 443
    security_groups = [
      var.albSgId
    ]
  }
  egress {
    from_port   = 0
    protocol    = "all"
    to_port     = 0
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  tags = {
    Name = "ecs-${var.serviceName}"
  }
  name = "ecs-${var.serviceName}"

}


resource "aws_alb_target_group" "tg" {
  count = var.nlb && var.connectToLB ?0 : 1
  //only non-nlb
  name  = "ecs-${var.serviceName}"
  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    timeout             = 20
    unhealthy_threshold = 2
    path                = var.healthCheckPath
    protocol            = "HTTPS"
  }
  target_type = "ip"
  protocol    = "HTTPS"
  vpc_id      = data.aws_cloudformation_export.vpcId.value
  port        = 443

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.cluster
}

//scheduled tasks
data "aws_iam_policy_document" "scheduled_task_cw_event_role_assume_role_policy" {
  count = !(length(var.scheduleCron) == 0) ? 1 : 0
  //only scheduled tasks
  statement {
    effect  = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      identifiers = [
        "events.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "scheduled_task_cw_event_role_cloudwatch_policy" {
  count = !(length(var.scheduleCron) == 0) ? 1 : 0
  //only scheduled tasks
  statement {
    effect  = "Allow"
    actions = [
      "ecs:RunTask"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "iam:PassRole"
    ]
    resources = aws_iam_role.ecs_task_role.arn == null ? [
      aws_iam_role.ecs_task_execution_role.arn
    ] : [
      aws_iam_role.ecs_task_execution_role.arn,
      aws_iam_role.ecs_task_role.arn
    ]
  }
}

resource "aws_iam_role" "scheduled_task_cw_event_role" {
  count              = !(length(var.scheduleCron) == 0) ? 1 : 0
  //only scheduled tasks
  name               = "${var.serviceName}-st-cw-role"
  assume_role_policy = data.aws_iam_policy_document.scheduled_task_cw_event_role_assume_role_policy[0].json
}

resource "aws_iam_role_policy" "scheduled_task_cw_event_role_cloudwatch_policy" {
  count  = !(length(var.scheduleCron) == 0) ? 1 : 0
  //only scheduled tasks
  name   = "${var.serviceName}-st-cw-policy"
  role   = aws_iam_role.scheduled_task_cw_event_role[0].id
  policy = data.aws_iam_policy_document.scheduled_task_cw_event_role_cloudwatch_policy[0].json
}

resource "aws_cloudwatch_event_rule" "event_rule" {
  count               = !(length(var.scheduleCron) == 0) ? 1 : 0
  //only scheduled tasks
  name                = var.serviceName
  schedule_expression = var.scheduleCron
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {

  count     = !(length(var.scheduleCron) == 0) ? 1 : 0
  //only scheduled tasks
  rule      = aws_cloudwatch_event_rule.event_rule[0].name
  target_id = var.serviceName
  arn       = data.aws_ecs_cluster.cluster.arn
  role_arn  = aws_iam_role.scheduled_task_cw_event_role[0].arn

  ecs_target {

    launch_type         = var.deploymentType
    platform_version    = var.deploymentType=="FARGATE"?"1.4.0" : null
    task_count          = var.desiredCount
    task_definition_arn = "${local.taskDefinitionArn}"

    network_configuration {
      subnets          = split(",", data.aws_cloudformation_export.privateSubnets.value)
      assign_public_ip = false
      security_groups  = [
        aws_security_group.sg[0].id
      ]
    }

  }

}
//end scheduled tasks

resource "aws_ecs_service" "ecsService" {
  count            = !var.nlb && (length(var.scheduleCron) == 0) ? 1 : 0
  //only non-nlb
  name             = var.serviceName
  task_definition  = "${data.aws_ecs_task_definition.taskDef.family}:${data.aws_ecs_task_definition.taskDef.revision}"
  cluster          = var.cluster
  platform_version = var.deploymentType=="FARGATE"?"1.4.0" : null
  dynamic "load_balancer" {
    for_each = var.connectToLB?[
      0
    ] : []
    content {
      container_name   = "stunnel"
      container_port   = 443
      target_group_arn = aws_alb_target_group.tg[0].arn
    }

  }
  network_configuration {
    subnets          = split(",", data.aws_cloudformation_export.privateSubnets.value)
    assign_public_ip = false
    security_groups  = [
      aws_security_group.sg[0].id
    ]
  }
  enable_execute_command            = true
  health_check_grace_period_seconds = var.connectToLB?200 : 0
  desired_count                     = var.desiredCount
  deployment_maximum_percent        = 200

  lifecycle {
    ignore_changes = [
      "capacity_provider_strategy"
    ]
  }

}

resource "aws_lb_listener_rule" "rule" {
  count        = !var.nlb && var.connectToLB ?1 : 0
  //only non-nlb
  listener_arn = var.listenerArn
  priority     = var.listenerPriority

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tg[0].arn
  }

  dynamic "condition" {
    for_each = length(var.listenerPath)>0?[
      1
    ] : []
    content {
      path_pattern {
        values = var.listenerPath
      }
    }
  }
  dynamic "condition" {
    for_each = length(var.listenerHosts)>0?[
      1
    ] : []
    content {
      host_header {
        values = var.listenerHosts
      }
    }
  }

}

//NLB ECS Service

variable "networkLbProtocol" {
  default = "TCP"
  validation {
    condition = (
    var.networkLbProtocol=="TCP" ||
    var.networkLbProtocol=="UDP" ||
    var.networkLbProtocol=="TLS"
    )
    error_message = "Only UDP or TCP or TLS protocols are supported."
  }
}


variable "NLBArn" {
}
variable "SSLPolicy" {
  default = ""
}
resource "aws_lb_listener" "NlbListeners" {
  count             = length(var.nlbPorts)
  load_balancer_arn = var.NLBArn
  port              = var.nlbPorts[count.index].nlbPort
  protocol          = var.networkLbProtocol

  certificate_arn = var.networkLbProtocol=="TLS"?var.networkLbCertificateArn : ""
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlbTargetGroup[count.index].arn
  }
  ssl_policy = var.networkLbProtocol=="TLS"?var.SSLPolicy : ""
}


locals {
  nlbSgPorts = contains(var.nlbPorts[*].servicePort, var.nlbHealthCheckPort)?var.nlbPorts : concat(var.nlbPorts, [
    {
      servicePort = var.nlbHealthCheckPort
      protocol    = "tcp"
    }
  ])
}

resource "aws_security_group" "sgNLB" {
  count  = var.nlb?1 : 0
  vpc_id = data.aws_cloudformation_export.vpcId.value
  dynamic "ingress" {
    for_each = local.nlbSgPorts
    content {
      from_port   = ingress.value.servicePort
      to_port     = ingress.value.servicePort
      protocol    = ingress.value.protocol
      cidr_blocks = [
        "10.0.0.0/8"
      ]
    }
  }
  egress {
    from_port   = 0
    protocol    = "all"
    to_port     = 0
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  tags = {
    Name = "ecs-${var.serviceName}"
  }
  name = "ecs-${var.serviceName}"
}

#resource "aws_security_group_rule" "ServiceHealthPortSgRule" {
#  depends_on = [aws_security_group.sgNLB]
#  count=contains(var.nlbPorts[*].servicePort,var.nlbHealthCheckPort)?0:1
#  from_port         = var.nlbHealthCheckPort
#  protocol          = "TCP"
#  security_group_id = aws_security_group.sgNLB[0].id
#  to_port           = var.nlbHealthCheckPort
#  type              = "ingress"
#}

resource "aws_lb_target_group" "nlbTargetGroup" {
  count                = var.nlb?length(var.nlbPorts) : 0
  protocol             = var.networkLbProtocol
  target_type          = "ip"
  name                 = "${var.serviceName}-${var.nlbPorts[count.index].nlbPort}"
  deregistration_delay = 120
  port                 = var.nlbPorts[0].servicePort
  //  load_balancing_algorithm_type = "least_outstanding_requests"
  slow_start           = 0
  dynamic "stickiness" {
    for_each = var.networkLbProtocol=="TLS"?[] : [
      0
    ]
    content {
      type    = "source_ip"
      enabled = true
    }
  }
  health_check {
    protocol            = "TCP"
    port                = var.nlbHealthCheckPort
    healthy_threshold   = 5
    unhealthy_threshold = 5
    enabled             = true
  }
  vpc_id = data.aws_cloudformation_export.vpcId.value


}
resource "aws_ecs_service" "nlbEcsService" {
  count            = var.nlb && (length(var.scheduleCron) == 0) ? 1 : 0
  name             = var.serviceName
  task_definition  = "${data.aws_ecs_task_definition.taskDef.family}:${data.aws_ecs_task_definition.taskDef.revision}"
  cluster          = var.cluster
  platform_version = var.deploymentType=="FARGATE"?"1.4.0" : null


  dynamic "load_balancer" {
    for_each = var.nlbPorts
    content {
      container_name   = load_balancer.value.containerName
      container_port   = load_balancer.value.servicePort
      target_group_arn = aws_lb_target_group.nlbTargetGroup[load_balancer.key].arn

    }
  }

  network_configuration {
    subnets          = split(",", data.aws_cloudformation_export.privateSubnets.value)
    assign_public_ip = false
    security_groups  = [
      aws_security_group.sgNLB[0].id
    ]
  }

  health_check_grace_period_seconds = 200
  desired_count                     = var.desiredCount
  deployment_maximum_percent        = 200

  lifecycle {
    ignore_changes = [
      "capacity_provider_strategy"
    ]
  }

}

output "taskRoleArn" {
  value = aws_iam_role.ecs_task_role.arn
}
output "taskRoleName" {
  value = aws_iam_role.ecs_task_role.name
}
output "taskExecutionRoleArn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}
output "taskExecutionRoleName" {
  value = aws_iam_role.ecs_task_execution_role.name
}
