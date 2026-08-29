# ============================================================
# AWS CONFIG SERVICE-LINKED ROLE
# ============================================================

resource "aws_iam_service_linked_role" "config" {
  provider = aws.development

  aws_service_name = "config.amazonaws.com"
}


# ============================================================
# AWS CONFIG RECORDER
# ============================================================

resource "aws_config_configuration_recorder" "day3" {
  provider = aws.development

  name     = "day3-config-recorder"
  role_arn = aws_iam_service_linked_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}


# ============================================================
# CONFIG DELIVERY BUCKET
# ============================================================

resource "aws_s3_bucket" "config" {
  provider = aws.development

  bucket        = "oluwasanyaogunsakin4999433-day3-config"
  force_destroy = true

  tags = {
    Name = "day3-config"
  }
}


resource "aws_s3_bucket_public_access_block" "config" {
  provider = aws.development

  bucket = aws_s3_bucket.config.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}


# ============================================================
# CONFIG BUCKET POLICY
# ============================================================

data "aws_iam_policy_document" "config_bucket" {

  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.config.arn
    ]
  }

  statement {
    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.config.arn}/AWSLogs/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}


resource "aws_s3_bucket_policy" "config" {
  provider = aws.development

  bucket = aws_s3_bucket.config.id
  policy = data.aws_iam_policy_document.config_bucket.json
}


# ============================================================
# AWS CONFIG DELIVERY CHANNEL
# ============================================================

resource "aws_config_delivery_channel" "day3" {
  provider = aws.development

  name           = "day3-config-delivery"
  s3_bucket_name = aws_s3_bucket.config.bucket

  depends_on = [
    aws_s3_bucket_policy.config
  ]
}


# ============================================================
# START AWS CONFIG RECORDING
# ============================================================

resource "aws_config_configuration_recorder_status" "day3" {
  provider = aws.development

  name       = aws_config_configuration_recorder.day3.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.day3
  ]
}