output "alb_dns" {
  description = "ALB public DNS"
  value       = aws_lb.web_alb.dns_name
}
