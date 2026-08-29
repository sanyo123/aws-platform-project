locals {
  ou_ids = merge(
    {
      for k, v in aws_organizations_organizational_unit.org_units :
      k => v.id
    },
    {
      for k, v in aws_organizations_organizational_unit.workload_ous :
      k => v.id
    }
  )
}

locals {
  scp_attachments = {
    deny_leave_organization = {
      policy_key = "deny_leave_organization"
      target_id  = aws_organizations_organization.current.roots[0].id
    }

    restrict_regions_workloads = {
      policy_key = "restrict_regions"
      target_id  = aws_organizations_organizational_unit.org_units["Workloads"].id
    }
  }
}