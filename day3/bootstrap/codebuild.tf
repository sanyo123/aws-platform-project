# ============================================================
# CODEBUILD - TERRAFORM PLAN
# ============================================================

resource "aws_codebuild_project" "terraform_plan" {
  name         = "day3-terraform-plan"
  description  = "Terraform plan for Day 3 workload"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "day3/buildspec/buildspec-plan.yml"
  }

  tags = {
    Name = "day3-terraform-plan"
  }
}


# ============================================================
# CODEBUILD - TERRAFORM APPLY
# ============================================================

resource "aws_codebuild_project" "terraform_apply" {
  name         = "day3-terraform-apply"
  description  = "Terraform apply for Day 3 workload"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "day3/buildspec/buildspec-apply.yml"
  }

  tags = {
    Name = "day3-terraform-apply"
  }
}