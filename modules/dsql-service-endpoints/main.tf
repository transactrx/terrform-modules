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
# LOCALS
############################################

# Deduplicate clusters by service name
locals {
  unique_dsql_clusters = [
    for k, v in {
      for cluster in var.dsql_clusters :
      cluster.dsql_service_name => cluster...
    } : v[0]
  ]
}


############################################
# SECURITY GROUPS
############################################

#resource "aws_security_group" "dsql_sg" {
#  count  = length(local.unique_dsql_clusters)
#  region= local.unique_dsql_clusters[count.index].region
#  name   = local.unique_dsql_clusters[count.index].dsql_service_name
#  vpc_id = local.unique_dsql_clusters[count.index].vpc_id
#  tags = {
#    Name = local.unique_dsql_clusters[count.index].dsql_service_name
#  }
#}

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

#resource "aws_vpc_security_group_ingress_rule" "dsql_ingress" {
#  count = length(local.unique_dsql_clusters)
#
#  security_group_id = aws_security_group.dsql_sg[count.index].id
#  from_port         = 5432
#  to_port           = 5432
#  ip_protocol       = "tcp"
#  cidr_ipv4         = local.unique_dsql_clusters[count.index].vpc_cidr
#  region= local.unique_dsql_clusters[count.index].region
#}

resource "aws_vpc_security_group_ingress_rule" "dsql_ingress" {
  for_each = aws_security_group.dsql_sg

  security_group_id = each.value.id
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
  cidr_ipv4         = var.dsql_clusters[lookup(keys(aws_security_group.dsql_sg), each.key)].vpc_cidr
  region            = var.dsql_clusters[lookup(keys(aws_security_group.dsql_sg), each.key)].region
}

############################################
# VPC ENDPOINTS
############################################

#resource "aws_vpc_endpoint" "dsql_endpoint" {
#  count               = length(local.unique_dsql_clusters)
#  vpc_id              = local.unique_dsql_clusters[count.index].vpc_id
#  subnet_ids          = local.unique_dsql_clusters[count.index].subnet_ids
#  service_name        = local.unique_dsql_clusters[count.index].dsql_service_name
#  vpc_endpoint_type   = "Interface"
#  security_group_ids  = [aws_security_group.dsql_sg[count.index].id]
#  private_dns_enabled = true
#  region= local.unique_dsql_clusters[count.index].region
#}
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

#locals {
#  service_name_to_dns = {
#    for idx, endpoint in aws_vpc_endpoint.dsql_endpoint :
#    local.unique_dsql_clusters[idx].dsql_service_name => replace(
#      [
#        for entry in endpoint.dns_entry :
#        entry.dns_name if startswith(entry.dns_name, "*") && !strcontains(entry.dns_name, "vpce-")
#      ][0],
#      "*",
#      local.unique_dsql_clusters[idx].dsql_id
#    )
#  }
#}
locals {
  service_name_to_dns = {
    for k, endpoint in aws_vpc_endpoint.dsql_endpoint :
    k => replace(
      [
        for entry in endpoint.dns_entry :
        entry.dns_name if startswith(entry.dns_name, "*") && !strcontains(entry.dns_name, "vpce-")
      ][0],
      "*",
      var.dsql_clusters[lookup(keys(aws_vpc_endpoint.dsql_endpoint), k)].dsql_id
    )
  }
}

############################################
# SSM PARAMETERS
############################################

#resource "aws_ssm_parameter" "dns_param" {
#  count  = length(var.dsql_clusters)
#  name   = "dsql_${var.dsql_clusters[count.index].name}_dns"
#  type   = "String"
#  value  = local.service_name_to_dns[var.dsql_clusters[count.index].dsql_service_name]
#  region= local.unique_dsql_clusters[count.index].region
#}
#
#resource "aws_ssm_parameter" "arn_param" {
#  count  = length(var.dsql_clusters)
#  name   = "dsql_${var.dsql_clusters[count.index].name}_arn"
#  type   = "String"
#  value  = var.dsql_clusters[count.index].dsql_arn
#  region= local.unique_dsql_clusters[count.index].region
#}
resource "aws_ssm_parameter" "dns_param" {
  for_each = aws_vpc_endpoint.dsql_endpoint

  name   = "dsql_${var.dsql_clusters[lookup(keys(aws_vpc_endpoint.dsql_endpoint), each.key)].name}_dns"
  type   = "String"
  value  = local.service_name_to_dns[each.key]
  region = each.value.region
}

resource "aws_ssm_parameter" "arn_param" {
  for_each = aws_vpc_endpoint.dsql_endpoint

  name   = "dsql_${var.dsql_clusters[lookup(keys(aws_vpc_endpoint.dsql_endpoint), each.key)].name}_arn"
  type   = "String"
  value  = var.dsql_clusters[lookup(keys(aws_vpc_endpoint.dsql_endpoint), each.key)].dsql_arn
  region = each.value.region
}
############################################
# OUTPUTS
############################################
#
#output "private_dns_domains" {
#  description = "Private DNS domains for each DSQL cluster"
#  value = [
#    for cluster in var.dsql_clusters :
#    local.service_name_to_dns[cluster.dsql_service_name]
#  ]
#}

output "private_dns_domains" {
  description = "Private DNS domains for each DSQL cluster"
  value = [for k, v in local.service_name_to_dns : v]
}