
# ============================================================
# CODEBUILD TRUST POLICY
# ============================================================

data "aws_iam_policy_document" "codebuild_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}


# ============================================================
# CODEBUILD SERVICE ROLE - MANAGEMENT ACCOUNT
# ============================================================

resource "aws_iam_role" "codebuild" {
  name = "Day3CodeBuildRole"

  assume_role_policy = data.aws_iam_policy_document.codebuild_trust.json

  tags = {
    Name = "Day3CodeBuildRole"
  }
}


# ============================================================
# TERRAFORM EXECUTION ROLE TRUST POLICY
# DEVELOPMENT ACCOUNT
# ============================================================

data "aws_iam_policy_document" "terraform_execution_trust" {
  statement {
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        aws_iam_role.codebuild.arn
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}


# ============================================================
# TERRAFORM EXECUTION ROLE - DEVELOPMENT ACCOUNT
# ============================================================

resource "aws_iam_role" "terraform_execution" {
  provider = aws.development

  name = "Day3TerraformExecutionRole"

  assume_role_policy = data.aws_iam_policy_document.terraform_execution_trust.json

  tags = {
    Name = "Day3TerraformExecutionRole"
  }
}


# ============================================================
# ALLOW CODEBUILD TO ASSUME TERRAFORM EXECUTION ROLE
# ============================================================

data "aws_iam_policy_document" "codebuild_permissions" {

  statement {
    sid    = "AssumeTerraformExecutionRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      aws_iam_role.terraform_execution.arn
    ]
  }


  # ==========================================================
  # TERRAFORM REMOTE STATE
  # ==========================================================

  statement {
    sid    = "ListTerraformStateBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::oluwasanyaogunsakin4999433-day3-tfstate"
    ]
  }

  statement {
    sid    = "ManageTerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::oluwasanyaogunsakin4999433-day3-tfstate/*"
    ]
  }


  # ==========================================================
  # CODEBUILD LOGGING
  # ==========================================================

  statement {
    sid    = "CodeBuildLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}


resource "aws_iam_policy" "codebuild" {
  name = "Day3CodeBuildPolicy"

  policy = data.aws_iam_policy_document.codebuild_permissions.json
}


resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.codebuild.arn
}


# ============================================================
# TERRAFORM EXECUTION PERMISSIONS
# DEVELOPMENT ACCOUNT
# ============================================================

resource "aws_iam_role_policy_attachment" "terraform_execution_admin" {
  provider = aws.development

  role       = aws_iam_role.terraform_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}