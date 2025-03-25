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



resource "aws_rds_cluster" "aurora_postgres_cluster" {
  cluster_identifier          = "${var.name}-cluster"
  engine                      = "aurora-postgresql"
  engine_version              = "16.1" # Specify the desired PostgreSQL version
  database_name               = var.name
  master_username             = "sa"
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids      = [aws_security_group.aurora_sg.id] # Define a security group for Aurora
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

  tags = {
    Name = "Aurora PostgreSQL Instance"
  }
}
