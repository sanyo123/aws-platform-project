# ============================================================
# EC2 TRUST POLICY
# ============================================================

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}


data "aws_iam_policy_document" "workload" {

  statement {
    sid    = "ReadApplicationSecret"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      aws_secretsmanager_secret.app.arn
    ]
  }

  statement {
    sid    = "DecryptApplicationSecret"
    effect = "Allow"

    actions = [
      "kms:Decrypt"
    ]

    resources = [
      aws_kms_key.day3.arn
    ]
  }
}

data "aws_caller_identity" "development" {
  provider = aws.development
}