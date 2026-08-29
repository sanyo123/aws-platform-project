terraform {
  backend "s3" {
    bucket       = "oluwasanyaogunsakin4999433-day3-tfstate"
    key          = "day3/workload/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}