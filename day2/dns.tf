# ============================================================
# PRIVATE HOSTED ZONE - SHARED SERVICES
# ============================================================

resource "aws_route53_zone" "private" {
  provider = aws.shared_services

  name = "platform.internal"

  vpc {
    vpc_id     = aws_vpc.shared_services.id
    vpc_region = "eu-west-2"
  }

  tags = {
    Name = "platform.internal"
  }
}


# ============================================================
# AUTHORISE CROSS-ACCOUNT VPC ASSOCIATIONS
# ============================================================

resource "aws_route53_vpc_association_authorization" "development" {
  provider = aws.shared_services

  zone_id    = aws_route53_zone.private.zone_id
  vpc_id     = aws_vpc.development.id
  vpc_region = "eu-west-2"
}


resource "aws_route53_vpc_association_authorization" "production" {
  provider = aws.shared_services

  zone_id    = aws_route53_zone.private.zone_id
  vpc_id     = aws_vpc.production.id
  vpc_region = "eu-west-2"
}


# ============================================================
# ASSOCIATE DEVELOPMENT VPC
# ============================================================

resource "aws_route53_zone_association" "development" {
  provider = aws.development

  zone_id    = aws_route53_zone.private.zone_id
  vpc_id     = aws_vpc.development.id
  vpc_region = "eu-west-2"

  depends_on = [
    aws_route53_vpc_association_authorization.development
  ]
}


# ============================================================
# ASSOCIATE PRODUCTION VPC
# ============================================================

resource "aws_route53_zone_association" "production" {
  provider = aws.production

  zone_id    = aws_route53_zone.private.zone_id
  vpc_id     = aws_vpc.production.id
  vpc_region = "eu-west-2"

  depends_on = [
    aws_route53_vpc_association_authorization.production
  ]
}


resource "aws_route53_record" "production_app" {
  provider = aws.shared_services

  zone_id = aws_route53_zone.private.zone_id
  name    = "app.platform.internal"
  type    = "A"
  ttl     = 60

  records = [
    aws_instance.production_test.private_ip
  ]
}