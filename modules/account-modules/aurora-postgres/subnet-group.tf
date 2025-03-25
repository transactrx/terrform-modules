resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "Aurora PostgreSQL Subnet Group"
  }
}
