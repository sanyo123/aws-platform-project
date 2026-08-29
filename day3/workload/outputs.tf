# ============================================================
# EC2 WORKLOAD
# ============================================================

output "workload_instance_id" {
  description = "EC2 instance ID for the Day 3 workload"
  value       = aws_instance.workload.id
}

output "workload_private_ip" {
  description = "Private IP address of the Day 3 EC2 workload"
  value       = aws_instance.workload.private_ip
}

output "workload_public_ip" {
  description = "Public IP address of the Day 3 EC2 workload"
  value       = aws_instance.workload.public_ip
}


# ============================================================
# SECRETS MANAGER
# ============================================================

output "application_secret_arn" {
  description = "ARN of the Day 3 application secret"
  value       = aws_secretsmanager_secret.app.arn
}

output "application_secret_name" {
  description = "Name of the Day 3 application secret"
  value       = aws_secretsmanager_secret.app.name
}


# ============================================================
# KMS
# ============================================================

output "kms_key_arn" {
  description = "ARN of the Day 3 customer-managed KMS key"
  value       = aws_kms_key.day3.arn
}

output "kms_alias" {
  description = "Alias of the Day 3 KMS key"
  value       = aws_kms_alias.day3.name
}


# ============================================================
# SECURITY SERVICES
# ============================================================

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = aws_guardduty_detector.day3.id
}

output "detective_graph_arn" {
  description = "Amazon Detective behavior graph ARN"
  value       = aws_detective_graph.day3.graph_arn
}

output "securityhub_arn" {
  description = "Security Hub account ARN"
  value       = aws_securityhub_account.day3.arn
}


# ============================================================
# MONITORING
# ============================================================

output "cloudwatch_alarm_name" {
  description = "CloudWatch CPU alarm name"
  value       = aws_cloudwatch_metric_alarm.high_cpu.alarm_name
}

output "sns_topic_arn" {
  description = "SNS topic used for Day 3 workload alerts"
  value       = aws_sns_topic.day3_alerts.arn
}