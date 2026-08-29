output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "aws_organization_id" {
  value = aws_organizations_organization.current.id
}

output "aws_organization_root_id" {
  value = aws_organizations_organization.current.roots[0].id
}

output "organizational_unit_ids" {
  description = "IDs of the AWS Organizational Units"

  value = {
    for k, v in aws_organizations_organizational_unit.org_units :
    k => v.id
  }
}

output "workload_organizational_unit_ids" {
  description = "IDs of the AWS Workload Organizational Units"

  value = {
    for k, v in aws_organizations_organizational_unit.workload_ous :
    k => v.id
  }
}

output "account_id" {
  description = "IDs of the AWS member accounts"

  value = {
    for k, v in aws_organizations_account.account :
    k => v.id
  }
}

output "audit_bucket_ids" {
  value = {
    for k, v in aws_s3_bucket.cloudtrail_logs :
    k => v.id
  }
}

output "audit_bucket_arns" {
  value = {
    for k, v in aws_s3_bucket.cloudtrail_logs :
    k => v.arn
  }
}

output "organization_cloudtrail_arns" {
  value = {
    for k, v in aws_cloudtrail.organization :
    k => v.arn
  }
}