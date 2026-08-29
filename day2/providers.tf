terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Management account - default provider
provider "aws" {
  region  = "eu-west-2"
  profile = "platform-admin"
}

# Development account
provider "aws" {
  alias   = "development"
  region  = "eu-west-2"
  profile = "development-admin"
}

# Security Tooling account
provider "aws" {
  alias   = "security"
  region  = "eu-west-2"
  profile = "security-admin"
}

# Shared Services account
provider "aws" {
  alias   = "shared_services"
  region  = "eu-west-2"
  profile = "shared-services-admin"
}

# Production account
provider "aws" {
  alias   = "production"
  region  = "eu-west-2"
  profile = "production-admin"
}