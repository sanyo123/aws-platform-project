resource "aws_organizations_organization" "current" {
  feature_set = "ALL"

  aws_service_access_principals = [
    "sso.amazonaws.com",
    "cloudtrail.amazonaws.com"
  ]

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY"
  ]
}


resource "aws_organizations_organizational_unit" "org_units" {
  for_each = var.org_units

  name      = each.value
  parent_id = aws_organizations_organization.current.roots[0].id
}

resource "aws_organizations_organizational_unit" "workload_ous" {
  for_each = var.workload_ous

  name      = each.value
  parent_id = aws_organizations_organizational_unit.org_units["Workloads"].id
}

resource "aws_organizations_account" "account" {
  for_each = var.ou_accounts

  name      = each.value.name
  email     = each.value.email
  parent_id = local.ou_ids[each.value.ou]
}

resource "aws_organizations_policy" "scp" {
  for_each = var.service_control_policies

  name        = each.value.name
  description = each.value.description
  type        = "SERVICE_CONTROL_POLICY"

  content = file("${path.module}/policies/${each.value.policy_file}")
}

resource "aws_organizations_policy_attachment" "scp" {
  for_each = local.scp_attachments

  policy_id = aws_organizations_policy.scp[each.value.policy_key].id
  target_id = each.value.target_id
}




resource "aws_s3_bucket" "cloudtrail_logs" {
  provider = aws.security
  for_each = var.audit_buckets

  bucket = each.value.bucket_name

  tags = {
    Name      = each.value.bucket_name
    Purpose   = "Organization CloudTrail audit logs"
    ManagedBy = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  provider = aws.security
  for_each = var.audit_buckets

  bucket = aws_s3_bucket.cloudtrail_logs[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  provider = aws.security
  for_each = var.audit_buckets

  bucket = aws_s3_bucket.cloudtrail_logs[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  provider = aws.security
  for_each = var.audit_buckets

  bucket = aws_s3_bucket.cloudtrail_logs[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  provider = aws.security
  for_each = var.cloudtrails

  bucket = aws_s3_bucket.cloudtrail_logs[each.value.bucket_key].id

  policy = data.aws_iam_policy_document.central_audit_bucket.json
}

resource "aws_cloudtrail" "organization" {
  for_each = var.cloudtrails

  name           = each.value.trail_name
  s3_bucket_name = aws_s3_bucket.cloudtrail_logs[each.value.bucket_key].id

  is_organization_trail         = true
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_logging                = true
  enable_log_file_validation    = true

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cloudwatch.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  depends_on = [
    aws_s3_bucket_policy.cloudtrail_logs,
    aws_iam_role_policy.cloudtrail_cloudwatch
  ]
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_logs" {
  provider = aws.security
  for_each = var.audit_buckets

  bucket = aws_s3_bucket.cloudtrail_logs[each.key].id

  rule {
    id     = "expire-cloudtrail-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = each.value.retention_days
    }
  }
}



resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/organization"
  retention_in_days = 30

  tags = {
    Name      = "organization-cloudtrail-logs"
    Purpose   = "CloudTrail operational monitoring"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role" "cloudtrail_cloudwatch" {
  name = "CloudTrailCloudWatchLogsRole"

  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  name = "CloudTrailCloudWatchLogsPolicy"
  role = aws_iam_role.cloudtrail_cloudwatch.id

  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch.json
}


resource "aws_cloudwatch_log_metric_filter" "security" {
  for_each = var.cloudwatch_metric_filters

  name           = each.key
  pattern        = each.value.pattern
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name      = each.value.metric_name
    namespace = each.value.metric_namespace
    value     = "1"
  }
}


resource "aws_cloudwatch_metric_alarm" "security" {
  for_each = var.cloudwatch_metric_filters

  alarm_name          = each.value.alarm_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1

  metric_name = each.value.metric_name
  namespace   = each.value.metric_namespace

  period    = 300
  statistic = "Sum"
  threshold = 1

  treat_missing_data = "notBreaching"

  # Send ALARM notifications to SNS
  alarm_actions = [
    aws_sns_topic.security_alerts.arn
  ]

  depends_on = [
    aws_cloudwatch_log_metric_filter.security
  ]
}




# ============================================================
# SNS - SECURITY ALERTS
# ============================================================

resource "aws_sns_topic" "security_alerts" {
  name = "security-alerts"

  tags = {
    Name      = "security-alerts"
    Purpose   = "Organization security monitoring"
    ManagedBy = "Terraform"
  }
}


resource "aws_sns_topic_subscription" "security_alerts_email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = "sanyo4god2018@gmail.com"
}

resource "aws_iam_role" "config" {
  provider = aws.development

  name = "AWSConfigRecorderRole"

  assume_role_policy = data.aws_iam_policy_document.config_assume_role.json

  tags = {
    ManagedBy = "Terraform"
    Purpose   = "AWS Config resource recording"
  }
}

resource "aws_iam_role_policy_attachment" "config" {
  provider = aws.development

  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_iam_role_policy" "config_s3_access" {
  provider = aws.development

  name = "AWSConfigS3DeliveryAccess"
  role = aws_iam_role.config.id

  policy = data.aws_iam_policy_document.config_s3_access.json
}

resource "aws_config_configuration_recorder" "development" {
  provider = aws.development

  name     = "development-config-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = false
    include_global_resource_types = false

    resource_types = [
      "AWS::S3::Bucket"
    ]
  }

  recording_mode {
    recording_frequency = "CONTINUOUS"
  }

  depends_on = [
    aws_iam_role_policy_attachment.config,
    aws_iam_role_policy.config_s3_access
  ]
}


resource "aws_config_delivery_channel" "development" {
  provider = aws.development

  name           = "development-config-delivery"
  s3_bucket_name = aws_s3_bucket.cloudtrail_logs["organization_logs"].bucket

  depends_on = [
    aws_config_configuration_recorder.development,
    aws_s3_bucket_policy.cloudtrail_logs
  ]
}




resource "aws_s3_bucket" "config_test" {
  provider = aws.development

  bucket = "sanyo-config-test-207199379063"

  tags = {
    Name        = "config-test"
    Environment = "Development"
    ManagedBy   = "Terraform"
    Purpose     = "AWS Config compliance testing"
  }
}

resource "aws_config_config_rule" "s3_versioning" {
  provider = aws.development

  name = "s3-bucket-versioning-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }

  scope {
    compliance_resource_types = [
      "AWS::S3::Bucket"
    ]
  }

  depends_on = [
    aws_config_configuration_recorder.development,
    aws_config_configuration_recorder_status.development
  ]
}


resource "aws_config_configuration_recorder_status" "development" {
  provider = aws.development

  name       = aws_config_configuration_recorder.development.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.development
  ]
}

resource "aws_s3_bucket_versioning" "config_test" {
  provider = aws.development

  bucket = aws_s3_bucket.config_test.id

  versioning_configuration {
    status = "Enabled"
  }
}