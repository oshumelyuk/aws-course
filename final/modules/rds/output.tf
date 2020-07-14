# Output variable definitions

output "rds_host" {
  description = "RDS host"
  value       = aws_db_instance.ac_rds.address
}

output "rds_arn" {
  description = "RDS ARN"
  value       = aws_db_instance.ac_rds.arn
}