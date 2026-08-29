# ============================================================
# GUARDDUTY
# ============================================================

resource "aws_guardduty_detector" "day3" {
  provider = aws.development

  enable = true

  tags = {
    Name = "day3-guardduty"
  }
}


# ============================================================
# AMAZON INSPECTOR
# ============================================================

resource "aws_inspector2_enabler" "day3" {
  provider = aws.development

  account_ids = [
    data.aws_caller_identity.development.account_id
  ]

  resource_types = [
    "EC2"
  ]
}


# ============================================================
# SECURITY HUB
# ============================================================

resource "aws_securityhub_account" "day3" {
  provider = aws.development

  enable_default_standards = true
}


# ============================================================
# AMAZON DETECTIVE
# ============================================================

resource "aws_detective_graph" "day3" {
  provider = aws.development

  tags = {
    Name = "day3-detective"
  }
}
