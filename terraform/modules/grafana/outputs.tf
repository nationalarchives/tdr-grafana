output "alb_security_group_id" {
  value = aws_security_group.grafana_alb_group.id
}

output "public_subnets" {
  value = aws_subnet.public.*.id
}
