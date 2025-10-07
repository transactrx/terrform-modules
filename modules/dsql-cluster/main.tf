############################################
# VARIABLES
############################################

variable "name" {
  description = "Name tag for both DSQL clusters"
  type        = string
}

variable "primary_region" {
  description = "Region for the primary DSQL cluster"
  type        = string
}

variable "secondary_region" {
  description = "Region for the secondary DSQL cluster"
  type        = string
}

variable "witness_region" {
  description = "Region to use as the witness in multi-region properties"
  type        = string
}

variable "ssm_prefix" {
  description = "Prefix for SSM parameter names (e.g. /transactrx/dsql)"
  type        = string
}

variable "deletion_protection_enabled" {
  description = "Whether deletion protection is enabled"
  type        = bool
  default     = true
}

############################################
# PRIMARY CLUSTER
############################################

resource "aws_dsql_cluster" "primary" {
  region                      = var.primary_region
  deletion_protection_enabled = var.deletion_protection_enabled

  tags = {
    Name = "${var.name}-primary"
  }

  multi_region_properties {
    witness_region = var.witness_region
  }
}

############################################
# SECONDARY CLUSTER
############################################

resource "aws_dsql_cluster" "secondary" {
  region                      = var.secondary_region
  deletion_protection_enabled = var.deletion_protection_enabled

  tags = {
    Name = "${var.name}-secondary"
  }

  multi_region_properties {
    witness_region = var.witness_region
  }
}

############################################
# SAVE ARNs TO SSM
############################################

resource "aws_ssm_parameter" "primary_arn" {
  name  = "${var.ssm_prefix}/cluster-arn-primary"
  type  = "String"
  value = aws_dsql_cluster.primary.arn
}

resource "aws_ssm_parameter" "secondary_arn" {
  name  = "${var.ssm_prefix}/cluster-arn-secondary"
  type  = "String"
  value = aws_dsql_cluster.secondary.arn
}

############################################
# PEERING (BI-DIRECTIONAL)
############################################

# Primary -> Secondary
resource "aws_dsql_cluster_peering" "primary_to_secondary" {
  depends_on     = [aws_dsql_cluster.primary, aws_dsql_cluster.secondary]
  region         = var.primary_region
  identifier     = aws_dsql_cluster.primary.identifier
  clusters       = [aws_dsql_cluster.secondary.arn]
  witness_region = var.witness_region
}

# Secondary -> Primary
resource "aws_dsql_cluster_peering" "secondary_to_primary" {
  depends_on     = [aws_dsql_cluster.primary, aws_dsql_cluster.secondary]
  region         = var.secondary_region
  identifier     = aws_dsql_cluster.secondary.identifier
  clusters       = [aws_dsql_cluster.primary.arn]
  witness_region = var.witness_region
}

############################################
# OUTPUTS
############################################

output "primary_arn" {
  value = aws_dsql_cluster.primary.arn
}

output "secondary_arn" {
  value = aws_dsql_cluster.secondary.arn
}

output "primary_identifier" {
  value = aws_dsql_cluster.primary.identifier
}

output "secondary_identifier" {
  value = aws_dsql_cluster.secondary.identifier
}

output "primary_vpc_endpoint_service_name" {
  description = "VPC endpoint service name for the primary DSQL cluster"
  value       = aws_dsql_cluster.primary.vpc_endpoint_service_name
}

output "secondary_vpc_endpoint_service_name" {
  description = "VPC endpoint service name for the secondary DSQL cluster"
  value       = aws_dsql_cluster.secondary.vpc_endpoint_service_name
}