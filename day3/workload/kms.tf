# ============================================================
# CUSTOMER-MANAGED KMS KEY
# ============================================================

resource "aws_kms_key" "day3" {
  provider = aws.development

  description             = "Day 3 workload encryption key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "day3-workload-kms"
  }
}

resource "aws_kms_alias" "day3" {
  provider = aws.development

  name          = "alias/day3-workload"
  target_key_id = aws_kms_key.day3.key_id
}