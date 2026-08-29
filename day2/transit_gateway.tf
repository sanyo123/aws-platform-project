# ============================================================
# CENTRAL TRANSIT GATEWAY - SHARED SERVICES
# ============================================================

resource "aws_ec2_transit_gateway" "central" {
  provider = aws.shared_services

  description = "Central transit gateway for Day 2 lab"

  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"

  tags = {
    Name = "day2-central-tgw"
  }
}


# ============================================================
# AWS RAM SHARE
# ============================================================

resource "aws_ram_resource_share" "transit_gateway" {
  provider = aws.shared_services

  name                      = "day2-tgw-share"
  allow_external_principals = false
}


resource "aws_ram_resource_association" "transit_gateway" {
  provider = aws.shared_services

  resource_share_arn = aws_ram_resource_share.transit_gateway.arn
  resource_arn       = aws_ec2_transit_gateway.central.arn
}


resource "aws_ram_principal_association" "development" {
  provider = aws.shared_services

  resource_share_arn = aws_ram_resource_share.transit_gateway.arn
  principal          = data.aws_caller_identity.development.account_id
}


resource "aws_ram_principal_association" "production" {
  provider = aws.shared_services

  resource_share_arn = aws_ram_resource_share.transit_gateway.arn
  principal          = data.aws_caller_identity.production.account_id
}


# ============================================================
# TGW VPC ATTACHMENTS
# ============================================================

resource "aws_ec2_transit_gateway_vpc_attachment" "development" {
  provider = aws.development

  vpc_id             = aws_vpc.development.id
  subnet_ids         = [aws_subnet.development_private.id]
  transit_gateway_id = aws_ec2_transit_gateway.central.id

  depends_on = [
    aws_ram_resource_association.transit_gateway,
    aws_ram_principal_association.development
  ]

  tags = {
    Name = "development-tgw-attachment"
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment" "production" {
  provider = aws.production

  vpc_id             = aws_vpc.production.id
  subnet_ids         = [aws_subnet.production_private.id]
  transit_gateway_id = aws_ec2_transit_gateway.central.id

  depends_on = [
    aws_ram_resource_association.transit_gateway,
    aws_ram_principal_association.production
  ]

  tags = {
    Name = "production-tgw-attachment"
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment" "shared_services" {
  provider = aws.shared_services

  vpc_id             = aws_vpc.shared_services.id
  subnet_ids         = [aws_subnet.shared_services_private.id]
  transit_gateway_id = aws_ec2_transit_gateway.central.id

  tags = {
    Name = "shared-services-tgw-attachment"
  }
}


# ============================================================
# VPC ROUTES TO TGW
# ============================================================

resource "aws_route" "development_to_production" {
  provider = aws.development

  route_table_id         = aws_route_table.development_private.id
  destination_cidr_block = "10.20.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.central.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.development
  ]
}


resource "aws_route" "development_to_shared_services" {
  provider = aws.development

  route_table_id         = aws_route_table.development_private.id
  destination_cidr_block = "10.30.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.central.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.development
  ]
}


resource "aws_route" "production_to_development" {
  provider = aws.production

  route_table_id         = aws_route_table.production_private.id
  destination_cidr_block = "10.10.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.central.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.production
  ]
}


resource "aws_route" "production_to_shared_services" {
  provider = aws.production

  route_table_id         = aws_route_table.production_private.id
  destination_cidr_block = "10.30.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.central.id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.production
  ]
}


resource "aws_route" "shared_services_to_development" {
  provider = aws.shared_services

  route_table_id         = aws_route_table.shared_services_private.id
  destination_cidr_block = "10.10.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.central.id
}


resource "aws_route" "shared_services_to_production" {
  provider = aws.shared_services

  route_table_id         = aws_route_table.shared_services_private.id
  destination_cidr_block = "10.20.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.central.id
}