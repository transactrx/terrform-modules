############################################
# VARIABLES
############################################

variable "dsql_clusters" {
  description = "List of DSQL clusters with network and service details"
  type = list(object({
    dsql_arn          = string
    dsql_id           = string
    dsql_service_name = string
    vpc_id            = string
    subnet_ids        = list(string)
    region            = string
    name              = string
    vpc_cidr          = string
  }))
}

############################################
# SECURITY GROUPS
############################################

resource "aws_security_group" "dsql_sg" {
  for_each = {
    for cluster in var.dsql_clusters :
    cluster.dsql_service_name => cluster
  }

  name   = each.key
  vpc_id = each.value.vpc_id
  region = each.value.region

  tags = {
    Name = each.key
  }
}

############################################
# INGRESS RULES
############################################

resource "aws_vpc_security_group_ingress_rule" "dsql_ingress" {
  for_each = aws_security_group.dsql_sg

  security_group_id = each.value.id
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"

  # Match cluster data by service name (safe, deterministic)
  cidr_ipv4 = var.dsql_clusters[
  index([for c in var.dsql_clusters : c.dsql_service_name], each.key)
  ].vpc_cidr

  region = var.dsql_clusters[
  index([for c in var.dsql_clusters : c.dsql_service_name], each.key)
  ].region
}

############################################
# VPC ENDPOINTS
############################################

resource "aws_vpc_endpoint" "dsql_endpoint" {
  for_each = {
    for cluster in var.dsql_clusters :
    cluster.dsql_service_name => cluster
  }

  vpc_id              = each.value.vpc_id
  subnet_ids          = each.value.subnet_ids
  service_name        = each.value.dsql_service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.dsql_sg[each.key].id]
  private_dns_enabled = true
  region              = each.value.region
}

############################################
# DNS MAPPING
############################################

locals {
  service_name_to_dns = {
    for k, endpoint in aws_vpc_endpoint.dsql_endpoint :
    k => replace(
      [
        for entry in endpoint.dns_entry :
        entry.dns_name if startswith(entry.dns_name, "*") && !strcontains(entry.dns_name, "vpce-")
      ][0],
      "*",
      var.dsql_clusters[
      index([for c in var.dsql_clusters : c.dsql_service_name], k)
      ].dsql_id
    )
  }
}

############################################
# SSM PARAMETERS
############################################

resource "aws_ssm_parameter" "dns_param" {
  for_each = aws_vpc_endpoint.dsql_endpoint

  name   = "dsql_${var.dsql_clusters[index([for c in var.dsql_clusters : c.dsql_service_name], each.key)].name}_dns"
  type   = "String"
  value  = local.service_name_to_dns[each.key]
  region = each.value.region
}

resource "aws_ssm_parameter" "arn_param" {
  for_each = aws_vpc_endpoint.dsql_endpoint

  name   = "dsql_${var.dsql_clusters[index([for c in var.dsql_clusters : c.dsql_service_name], each.key)].name}_arn"
  type   = "String"
  value  = var.dsql_clusters[index([for c in var.dsql_clusters : c.dsql_service_name], each.key)].dsql_arn
  region = each.value.region
}

############################################
# OUTPUTS
############################################

output "private_dns_domains" {
  description = "Private DNS domains for each DSQL cluster"
  value       = [for _, v in local.service_name_to_dns : v]
}