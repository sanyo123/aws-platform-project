# ============================================================
# GITHUB CONNECTION
# ============================================================

resource "aws_codestarconnections_connection" "github" {
  name          = "day3-github-connection"
  provider_type = "GitHub"

  tags = {
    Name = "day3-github-connection"
  }
}


# ============================================================
# CODEPIPELINE TRUST POLICY
# ============================================================

data "aws_iam_policy_document" "codepipeline_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}


# ============================================================
# CODEPIPELINE SERVICE ROLE
# ============================================================

resource "aws_iam_role" "codepipeline" {
  name = "Day3CodePipelineRole"

  assume_role_policy = data.aws_iam_policy_document.codepipeline_trust.json

  tags = {
    Name = "Day3CodePipelineRole"
  }
}


# ============================================================
# CODEPIPELINE PERMISSION POLICY
# ============================================================

data "aws_iam_policy_document" "codepipeline_permissions" {

  # ----------------------------------------------------------
  # PIPELINE ARTIFACT BUCKET
  # ----------------------------------------------------------

  statement {
    sid    = "ListArtifactBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::oluwasanyaogunsakin4999433-day3-tfstate"
    ]
  }

  statement {
    sid    = "ManagePipelineArtifacts"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::oluwasanyaogunsakin4999433-day3-tfstate/*"
    ]
  }


  # ----------------------------------------------------------
  # START CODEBUILD PROJECTS
  # ----------------------------------------------------------

  statement {
    sid    = "RunCodeBuild"
    effect = "Allow"

    actions = [
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds"
    ]

    resources = [
      aws_codebuild_project.terraform_plan.arn,
      aws_codebuild_project.terraform_apply.arn
    ]
  }


  # ----------------------------------------------------------
  # USE GITHUB CONNECTION
  # ----------------------------------------------------------

  statement {
    sid    = "UseGitHubConnection"
    effect = "Allow"

    actions = [
      "codestar-connections:UseConnection"
    ]

    resources = [
      aws_codestarconnections_connection.github.arn
    ]
  }
}


# ============================================================
# CREATE CODEPIPELINE POLICY
# ============================================================

resource "aws_iam_policy" "codepipeline" {
  name = "Day3CodePipelinePolicy"

  policy = data.aws_iam_policy_document.codepipeline_permissions.json
}


# ============================================================
# ATTACH POLICY TO CODEPIPELINE ROLE
# ============================================================

resource "aws_iam_role_policy_attachment" "codepipeline" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codepipeline.arn
}


# ============================================================
# DAY 3 CODEPIPELINE
# ============================================================

resource "aws_codepipeline" "day3" {
  name     = "day3-terraform-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = "oluwasanyaogunsakin4999433-day3-tfstate"
    type     = "S3"
  }


  # ==========================================================
  # SOURCE STAGE
  # ==========================================================

  stage {
    name = "Source"

    action {
      name             = "GitHubSource"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = var.github_repository
        BranchName       = var.github_branch
      }
    }
  }


  # ==========================================================
  # TERRAFORM PLAN STAGE
  # ==========================================================

  stage {
    name = "Plan"

    action {
      name             = "TerraformPlan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["plan_output"]
      configuration = {
        ProjectName = aws_codebuild_project.terraform_plan.name
      }
    }
  }


  # ==========================================================
  # MANUAL APPROVAL
  # ==========================================================

  stage {
    name = "Approval"

    action {
      name     = "ApproveTerraformApply"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }


  # ==========================================================
  # TERRAFORM APPLY STAGE
  # ==========================================================

  stage {
    name = "Apply"

    action {
      name            = "TerraformApply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["plan_output"]

      configuration = {
        ProjectName = aws_codebuild_project.terraform_apply.name
      }
    }
  }

  tags = {
    Name = "day3-terraform-pipeline"
  }
}