terraform {
  required_version = ">= 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}



provider "aws" {
  alias  = "development"
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::207199379063:role/Day3TerraformExecutionRole"
  }
}