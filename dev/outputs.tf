output "ec2_public_ips" {
  value = [aws_instance.backend_ec2_instance[*].public_ip]
}
output "rds_endpoint" {
  value = aws_db_instance.rds_database.address
}

output "postgres_password" {
  value = var.postgres_password
}

output "vigil_bot_ip" {
  value = aws_instance.vigil_bot_ec2_instance.public_ip
}

output "certificate_verification_cname" {
  value = tolist(aws_acm_certificate.default[*].domain_validation_options)[0]
}