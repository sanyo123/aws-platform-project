# ============================================================
# MANAGEMENT ACCOUNT
# ============================================================

# Information about the identity Terraform is currently using
data "aws_caller_identity" "management" {}


# Existing AWS Organization
data "aws_organizations_organization" "current" {}


# ============================================================
# DEVELOPMENT ACCOUNT
# ============================================================

data "aws_caller_identity" "development" {
  provider = aws.development
}


# ============================================================
# PRODUCTION ACCOUNT
# ============================================================

data "aws_caller_identity" "production" {
  provider = aws.production
}


# ============================================================
# SHARED SERVICES ACCOUNT
# ============================================================

data "aws_caller_identity" "shared_services" {
  provider = aws.shared_services
}


# ============================================================
# SECURITY TOOLING ACCOUNT
# ============================================================

data "aws_caller_identity" "security" {
  provider = aws.security
}

data "aws_ssm_parameter" "development_al2023" {
  provider = aws.development

  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}


data "aws_ssm_parameter" "production_al2023" {
  provider = aws.production

  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}
