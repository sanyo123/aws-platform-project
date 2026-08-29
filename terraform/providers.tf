terraform {
  required_version = ">= 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-2"
  profile = "platform-admin"
}

provider "aws" {
  alias   = "security"
  region  = "eu-west-2"
  profile = "security-admin"
}


provider "aws" {
  alias   = "development"
  region  = "eu-west-2"
  profile = "development-admin"
}