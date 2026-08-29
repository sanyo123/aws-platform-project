# ============================================================
# DEVELOPMENT VPC ENDPOINT SECURITY GROUP
# ============================================================

resource "aws_security_group" "development_ssm_endpoints" {
  provider = aws.development

  name        = "development-ssm-endpoints-sg"
  description = "Allow HTTPS from development VPC to SSM endpoints"
  vpc_id      = aws_vpc.development.id

  tags = {
    Name = "development-ssm-endpoints-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "development_ssm_https" {
  provider = aws.development

  security_group_id = aws_security_group.development_ssm_endpoints.id
  cidr_ipv4         = "10.10.0.0/16"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443

  description = "Allow HTTPS from development VPC"
}

resource "aws_vpc_security_group_egress_rule" "development_ssm_all" {
  provider = aws.development

  security_group_id = aws_security_group.development_ssm_endpoints.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# ============================================================
# DEVELOPMENT SYSTEMS MANAGER ENDPOINT
# ============================================================

resource "aws_vpc_endpoint" "development_ssm" {
  provider = aws.development

  vpc_id              = aws_vpc.development.id
  service_name        = "com.amazonaws.eu-west-2.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.development_private.id]
  security_group_ids  = [aws_security_group.development_ssm_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "development-ssm-endpoint"
  }
}


# ============================================================
# DEVELOPMENT SSM MESSAGES ENDPOINT
# ============================================================

resource "aws_vpc_endpoint" "development_ssmmessages" {
  provider = aws.development

  vpc_id              = aws_vpc.development.id
  service_name        = "com.amazonaws.eu-west-2.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.development_private.id]
  security_group_ids  = [aws_security_group.development_ssm_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "development-ssmmessages-endpoint"
  }
}


# ============================================================
# PRODUCTION VPC ENDPOINT SECURITY GROUP
# ============================================================

resource "aws_security_group" "production_ssm_endpoints" {
  provider = aws.production

  name        = "production-ssm-endpoints-sg"
  description = "Allow HTTPS from production VPC to SSM endpoints"
  vpc_id      = aws_vpc.production.id

  tags = {
    Name = "production-ssm-endpoints-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "production_ssm_https" {
  provider = aws.production

  security_group_id = aws_security_group.production_ssm_endpoints.id
  cidr_ipv4         = "10.20.0.0/16"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443

  description = "Allow HTTPS from production VPC"
}

resource "aws_vpc_security_group_egress_rule" "production_ssm_all" {
  provider = aws.production

  security_group_id = aws_security_group.production_ssm_endpoints.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# ============================================================
# PRODUCTION SYSTEMS MANAGER ENDPOINT
# ============================================================

resource "aws_vpc_endpoint" "production_ssm" {
  provider = aws.production

  vpc_id              = aws_vpc.production.id
  service_name        = "com.amazonaws.eu-west-2.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.production_private.id]
  security_group_ids  = [aws_security_group.production_ssm_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "production-ssm-endpoint"
  }
}


# ============================================================
# PRODUCTION SSM MESSAGES ENDPOINT
# ============================================================

resource "aws_vpc_endpoint" "production_ssmmessages" {
  provider = aws.production

  vpc_id              = aws_vpc.production.id
  service_name        = "com.amazonaws.eu-west-2.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.production_private.id]
  security_group_ids  = [aws_security_group.production_ssm_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "production-ssmmessages-endpoint"
  }
}