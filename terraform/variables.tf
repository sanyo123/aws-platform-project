variable "org_units" {
  description = "List of Organizational Units to create"
  type        = set(string)
}

variable "workload_ous" {
  description = "Nested workload OUs under the Workloads OU"
  type        = set(string)
}

variable "ou_accounts" {
  description = "AWS member accounts and their target Organizational Units"

  type = map(object({
    name  = string
    email = string
    ou    = string
  }))
}

variable "service_control_policies" {
  description = "Service Control Policies for the AWS Organization"

  type = map(object({
    name        = string
    description = string
    policy_file = string
  }))
}

variable "audit_buckets" {
  type = map(object({
    bucket_name    = string
    retention_days = number
  }))
}

variable "cloudtrails" {
  type = map(object({
    trail_name = string
    bucket_key = string
  }))
}

variable "cloudwatch_metric_filters" {
  type = map(object({
    pattern          = string
    metric_name      = string
    metric_namespace = string
    alarm_name       = string
    threshold        = number
    period           = number
  }))
}