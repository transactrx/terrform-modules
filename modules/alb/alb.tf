variable "name" {
  type = string
}
variable "private" {
  type = bool
}

variable "subnetIds" {
  type = list(string)
}

resource "aws_alb" "nlb" {
  name               = var.name
  internal           = var.private
  load_balancer_type = "network"
  subnets            = var.subnetIds

  enable_deletion_protection       = true
  enable_cross_zone_load_balancing = true

}


output "nlb_arn" {
  value = aws_alb.nlb.arn
}
output "nlb_name" {
  value = aws_alb.nlb.name
}
output "nlb_dns_name" {
  value = aws_alb.nlb.dns_name
}