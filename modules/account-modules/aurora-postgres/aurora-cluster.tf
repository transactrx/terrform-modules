variable "vpc_id" {
  description = "The VPC ID"
}
variable "subnet_ids" {
  type = list(string)
}
variable "name" {
}
variable "vpc_cidr" {
}
variable "instance_type" {
  default = "db.r7g.large"
}
variable "instance_count" {
  default = 1
}
variable "engine_version" {
  default = "16.1"
}

# The three variables below default to null, which Terraform sends as "unset".
# All three attributes are Optional+Computed in the AWS provider, so an unset
# value leaves whatever the cluster already has in place. Existing consumers
# therefore plan clean and keep their current backup and Performance Insights
# configuration.
variable "backup_retention_period" {
  description = "Days of automated backups to retain. Null leaves the cluster's current value unmanaged (AWS defaults new clusters to 1)."
  type        = number
  default     = null
}

variable "performance_insights_enabled" {
  description = "Enable RDS Performance Insights on the cluster instances. Null leaves the current value unmanaged."
  type        = bool
  default     = null
}

variable "performance_insights_retention_period" {
  description = "Days to retain Performance Insights data (7, or a multiple of 31 up to 731). Null uses the AWS default."
  type        = number
  default     = null
}

resource "aws_rds_cluster" "aurora_postgres_cluster" {
  cluster_identifier          = "${var.name}-cluster"
  engine                      = "aurora-postgresql"
  engine_version              = var.engine_version
  database_name               = var.name
  master_username             = "sa"
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids      = [aws_security_group.aurora_sg.id] # Define a security group for Aurora
  backup_retention_period     = var.backup_retention_period

  # Performance Insights is set on both the cluster and its instances. Aurora
  # carries the flag in both places, and a cluster that already has it enabled
  # would otherwise be reset to null the moment a consumer moves onto this
  # module while only the instance-level attribute is managed here.
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  tags = {
    Name = "Aurora PostgreSQL Cluster"
  }
}

resource "aws_rds_cluster_instance" "aurora_postgres_instance" {
  count              = var.instance_count # Number of instances in the cluster
  identifier         = "${var.name}-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora_postgres_cluster.id
  instance_class     = var.instance_type # ARM-based instance class
  engine             = aws_rds_cluster.aurora_postgres_cluster.engine
  engine_version     = aws_rds_cluster.aurora_postgres_cluster.engine_version

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  tags = {
    Name = "Aurora PostgreSQL Instance"
  }
}
