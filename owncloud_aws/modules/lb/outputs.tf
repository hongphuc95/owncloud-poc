output "alb_id" {
  value       = aws_alb.alb.dns_name
  description = "Domain name of the load balancer to access instances home page"
}
  
output "target_group_arn" {
  value = aws_alb_target_group.group.arn
  description = "Load balancer target group resource name"
}

output "alb_sg_id" {
  value = aws_security_group.alb-sg.id
  description = "Load balancer Security Group ID"
}