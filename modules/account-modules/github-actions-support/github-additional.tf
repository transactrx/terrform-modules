variable "private-subnet-ids" {
  type = string
}
variable "vpc-id" {
  type = string
}
resource "aws_ssm_parameter" "private-subnet-ids" {
  name  = "private-subnet-ids"
  type  = "String"
  value = var.private-subnet-ids
}

resource "aws_ssm_parameter" "vpc-id" {
  name  = "vpc-id"
  type  = "String"
  value = var.vpc-id
}
