output "account_mapping" {
  value = {
    management      = data.aws_caller_identity.management.account_id
    development     = data.aws_caller_identity.development.account_id
    production      = data.aws_caller_identity.production.account_id
    shared_services = data.aws_caller_identity.shared_services.account_id
    security        = data.aws_caller_identity.security.account_id
  }
}

output "development_instance_id" {
  value = aws_instance.development_test.id
}

output "development_private_ip" {
  value = aws_instance.development_test.private_ip
}

output "production_instance_id" {
  value = aws_instance.production_test.id
}

output "production_private_ip" {
  value = aws_instance.production_test.private_ip
}

output "private_dns_name" {
  value = aws_route53_record.production_app.fqdn
}