# ============================================================
# VPCS
# ============================================================

resource "aws_vpc" "development" {
  provider = aws.development

  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "development-vpc"
  }
}

resource "aws_vpc" "production" {
  provider = aws.production

  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "production-vpc"
  }
}

resource "aws_vpc" "shared_services" {
  provider = aws.shared_services

  cidr_block           = "10.30.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "shared-services-vpc"
  }
}


# ============================================================
# DEVELOPMENT SUBNET
# ============================================================

resource "aws_subnet" "development_private" {
  provider = aws.development

  vpc_id            = aws_vpc.development.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "development-private"
  }
}


# ============================================================
# PRODUCTION SUBNET
# ============================================================

resource "aws_subnet" "production_private" {
  provider = aws.production

  vpc_id            = aws_vpc.production.id
  cidr_block        = "10.20.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "production-private"
  }
}


# ============================================================
# SHARED SERVICES SUBNET
# ============================================================

resource "aws_subnet" "shared_services_private" {
  provider = aws.shared_services

  vpc_id            = aws_vpc.shared_services.id
  cidr_block        = "10.30.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "shared-services-private"
  }
}


# ============================================================
# DEVELOPMENT ROUTE TABLE
# ============================================================

resource "aws_route_table" "development_private" {
  provider = aws.development

  vpc_id = aws_vpc.development.id

  tags = {
    Name = "development-private-rt"
  }
}

resource "aws_route_table_association" "development_private" {
  provider = aws.development

  subnet_id      = aws_subnet.development_private.id
  route_table_id = aws_route_table.development_private.id
}


# ============================================================
# PRODUCTION ROUTE TABLE
# ============================================================

resource "aws_route_table" "production_private" {
  provider = aws.production

  vpc_id = aws_vpc.production.id

  tags = {
    Name = "production-private-rt"
  }
}

resource "aws_route_table_association" "production_private" {
  provider = aws.production

  subnet_id      = aws_subnet.production_private.id
  route_table_id = aws_route_table.production_private.id
}


# ============================================================
# SHARED SERVICES ROUTE TABLE
# ============================================================

resource "aws_route_table" "shared_services_private" {
  provider = aws.shared_services

  vpc_id = aws_vpc.shared_services.id

  tags = {
    Name = "shared-services-private-rt"
  }
}

resource "aws_route_table_association" "shared_services_private" {
  provider = aws.shared_services

  subnet_id      = aws_subnet.shared_services_private.id
  route_table_id = aws_route_table.shared_services_private.id
}


# ============================================================
# DEVELOPMENT SECURITY GROUP
# ============================================================

resource "aws_security_group" "development_workload" {
  provider = aws.development

  name        = "development-workload-sg"
  description = "Security group for development workload"
  vpc_id      = aws_vpc.development.id

  tags = {
    Name = "development-workload-sg"
  }
}


# ============================================================
# PRODUCTION SECURITY GROUP
# ============================================================

resource "aws_security_group" "production_workload" {
  provider = aws.production

  name        = "production-workload-sg"
  description = "Security group for production workload"
  vpc_id      = aws_vpc.production.id

  tags = {
    Name = "production-workload-sg"
  }
}


# ============================================================
# SHARED SERVICES SECURITY GROUP
# ============================================================

resource "aws_security_group" "shared_services_workload" {
  provider = aws.shared_services

  name        = "shared-services-workload-sg"
  description = "Security group for shared services workload"
  vpc_id      = aws_vpc.shared_services.id

  tags = {
    Name = "shared-services-workload-sg"
  }
}


# ============================================================
# DEVELOPMENT CUSTOM NACL
# ============================================================

resource "aws_network_acl" "development_private" {
  provider = aws.development

  vpc_id = aws_vpc.development.id

  subnet_ids = [
    aws_subnet.development_private.id
  ]

  tags = {
    Name = "development-private-nacl"
  }
}


# ============================================================
# DEVELOPMENT NACL - INBOUND
# ============================================================

resource "aws_network_acl_rule" "development_private_inbound" {
  provider = aws.development

  network_acl_id = aws_network_acl.development_private.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/8"
}


# ============================================================
# DEVELOPMENT NACL - OUTBOUND
# ============================================================

resource "aws_network_acl_rule" "development_private_outbound" {
  provider = aws.development

  network_acl_id = aws_network_acl.development_private.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/8"
}

# ============================================================
# DEVELOPMENT SECURITY GROUP RULES
# ============================================================

resource "aws_vpc_security_group_ingress_rule" "development_internal" {
  provider = aws.development

  security_group_id = aws_security_group.development_workload.id
  cidr_ipv4         = "10.0.0.0/8"
  ip_protocol       = "-1"

  description = "Allow internal AWS lab traffic"
}

resource "aws_vpc_security_group_egress_rule" "development_internal" {
  provider = aws.development

  security_group_id = aws_security_group.development_workload.id
  cidr_ipv4         = "10.0.0.0/8"
  ip_protocol       = "-1"

  description = "Allow internal AWS lab traffic"
}

# ============================================================
# PRODUCTION SECURITY GROUP RULES
# ============================================================

resource "aws_vpc_security_group_ingress_rule" "production_internal" {
  provider = aws.production

  security_group_id = aws_security_group.production_workload.id
  cidr_ipv4         = "10.0.0.0/8"
  ip_protocol       = "-1"

  description = "Allow internal AWS lab traffic"
}

resource "aws_vpc_security_group_egress_rule" "production_internal" {
  provider = aws.production

  security_group_id = aws_security_group.production_workload.id
  cidr_ipv4         = "10.0.0.0/8"
  ip_protocol       = "-1"

  description = "Allow internal AWS lab traffic"
}


# ============================================================
# SHARED SERVICES SECURITY GROUP RULES
# ============================================================

resource "aws_vpc_security_group_ingress_rule" "shared_services_internal" {
  provider = aws.shared_services

  security_group_id = aws_security_group.shared_services_workload.id
  cidr_ipv4         = "10.0.0.0/8"
  ip_protocol       = "-1"

  description = "Allow internal AWS lab traffic"
}

resource "aws_vpc_security_group_egress_rule" "shared_services_internal" {
  provider = aws.shared_services

  security_group_id = aws_security_group.shared_services_workload.id
  cidr_ipv4         = "10.0.0.0/8"
  ip_protocol       = "-1"

  description = "Allow internal AWS lab traffic"
}