
output "dns" {
  value = aws_lb.alb.dns_name
}

output "alb_arn" {
  value = aws_lb.alb.arn
}
output "tls_listener_arn" {
  value = aws_lb_listener.defaultListener443.arn
}

output "security_group_id" {
  value = aws_security_group.sg.id
}
output "security_group_arn" {
  value = aws_security_group.sg.id
}
