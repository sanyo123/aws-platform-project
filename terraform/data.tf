data "aws_caller_identity" "current" {}




data "aws_iam_policy_document" "cloudtrail_bucket" {
  for_each = var.cloudtrails

  statement {
    sid    = "AWSCloudTrailWrite20150319"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.cloudtrail_logs[each.value.bucket_key].arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]

    # CONDITION 1 GOES HERE
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    # CONDITION 2 GOES HERE
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:cloudtrail:eu-west-2:${data.aws_caller_identity.current.account_id}:trail/${each.value.trail_name}"
      ]
    }
  }

  statement {
    sid    = "AWSCloudTrailAclCheck20150319"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      aws_s3_bucket.cloudtrail_logs[each.value.bucket_key].arn
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:cloudtrail:eu-west-2:${data.aws_caller_identity.current.account_id}:trail/${each.value.trail_name}"
      ]
    }
  }

  statement {
    sid    = "AWSCloudTrailOrganizationWrite20150319"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.cloudtrail_logs[each.value.bucket_key].arn}/AWSLogs/${aws_organizations_organization.current.id}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:cloudtrail:eu-west-2:${data.aws_caller_identity.current.account_id}:trail/${each.value.trail_name}"
      ]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch" {

  statement {
    sid    = "AWSCloudTrailCreateLogStream"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream"
    ]

    resources = [
      "${aws_cloudwatch_log_group.cloudtrail.arn}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_*",
      "${aws_cloudwatch_log_group.cloudtrail.arn}:log-stream:${aws_organizations_organization.current.id}_*"
    ]
  }

  statement {
    sid    = "AWSCloudTrailPutLogEvents"
    effect = "Allow"

    actions = [
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.cloudtrail.arn}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_*",
      "${aws_cloudwatch_log_group.cloudtrail.arn}:log-stream:${aws_organizations_organization.current.id}_*"
    ]
  }
}

data "aws_iam_policy_document" "config_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "config_s3_access" {
  statement {
    sid    = "AWSConfigS3BucketCheck"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.cloudtrail_logs["organization_logs"].arn
    ]
  }
}

data "aws_iam_policy_document" "central_audit_bucket" {

  source_policy_documents = [
    data.aws_iam_policy_document.cloudtrail_bucket["organization"].json
  ]

  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      aws_s3_bucket.cloudtrail_logs["organization_logs"].arn
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = ["207199379063"]
    }
  }

  statement {
    sid    = "AWSConfigBucketExistenceCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.cloudtrail_logs["organization_logs"].arn
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = ["207199379063"]
    }
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
      "${aws_s3_bucket.cloudtrail_logs["organization_logs"].arn}/AWSLogs/207199379063/Config/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = ["207199379063"]
    }
  }
}

data "aws_iam_policy_document" "config_aggregator_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "config_aggregator" {
  name = "AWSConfigOrganizationAggregatorRole"

  assume_role_policy = data.aws_iam_policy_document.config_aggregator_assume_role.json

  tags = {
    ManagedBy = "Terraform"
    Purpose   = "AWS Config organization aggregation"
  }
}


resource "aws_iam_role_policy_attachment" "config_aggregator" {
  role = aws_iam_role.config_aggregator.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

resource "aws_config_configuration_aggregator" "organization" {
  name = "organization-config-aggregator"

  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.config_aggregator.arn
  }

  depends_on = [
    aws_iam_role_policy_attachment.config_aggregator
  ]

  tags = {
    ManagedBy = "Terraform"
    Purpose   = "Organization-wide AWS Config aggregation"
  }
}
