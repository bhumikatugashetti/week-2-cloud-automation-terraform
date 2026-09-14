output "application_url" {
  description = "Public URL of the application."
  value = "http://${aws_lb.public.dns_name}"
}

output "public_load_balancer_dns" {
  value = aws_lb.public.dns_name
}

output "internal_load_balancer_dns" {
  value = aws_lb.internal.dns_name
}

output "rds_endpoint" {
  description = "Private PostgreSQL endpoint."
  value = aws_db_instance.postgres.address
}

output "vpc_id" {
  value = aws_vpc.main.id
}
