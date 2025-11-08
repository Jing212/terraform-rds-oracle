output "rds_endpoint" {
  value       = module.db.db_instance_address
  description = "RDS endpoint"
}

output "rds_port" {
  value       = module.db.db_instance_port
  description = "RDS port"
}

output "rds_sg_id" {
  value       = aws_security_group.rds.id
  description = "RDS security group id"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC id"
}
