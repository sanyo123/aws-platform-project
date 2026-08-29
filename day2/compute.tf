# ============================================================
# TEMPORARY INTERNET ACCESS FOR SSM TESTING
# ============================================================

resource "aws_internet_gateway" "development" {
  provider = aws.development

  vpc_id = aws_vpc.development.id

  tags = {
    Name = "development-test-igw"
  }
}


resource "aws_internet_gateway" "production" {
  provider = aws.production

  vpc_id = aws_vpc.production.id

  tags = {
    Name = "production-test-igw"
  }
}


resource "aws_route" "development_internet" {
  provider = aws.development

  route_table_id         = aws_route_table.development_private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.development.id
}


resource "aws_route" "production_internet" {
  provider = aws.production

  route_table_id         = aws_route_table.production_private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.production.id
}

resource "aws_vpc_security_group_egress_rule" "development_https" {
  provider = aws.development

  security_group_id = aws_security_group.development_workload.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443

  description = "Temporary HTTPS egress for Systems Manager"
}


resource "aws_vpc_security_group_egress_rule" "production_https" {
  provider = aws.production

  security_group_id = aws_security_group.production_workload.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443

  description = "Temporary HTTPS egress for Systems Manager"
}


# ============================================================
# EC2 TRUST POLICY
# ============================================================

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}


# ============================================================
# DEVELOPMENT EC2 ROLE
# ============================================================

resource "aws_iam_role" "development_ec2" {
  provider = aws.development

  name               = "Day2DevelopmentEC2Role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}


resource "aws_iam_role_policy_attachment" "development_ssm" {
  provider = aws.development

  role       = aws_iam_role.development_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "development_ec2" {
  provider = aws.development

  name = "Day2DevelopmentEC2Profile"
  role = aws_iam_role.development_ec2.name
}


# ============================================================
# PRODUCTION EC2 ROLE
# ============================================================

resource "aws_iam_role" "production_ec2" {
  provider = aws.production

  name               = "Day2ProductionEC2Role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}


resource "aws_iam_role_policy_attachment" "production_ssm" {
  provider = aws.production

  role       = aws_iam_role.production_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "production_ec2" {
  provider = aws.production

  name = "Day2ProductionEC2Profile"
  role = aws_iam_role.production_ec2.name
}

# ============================================================
# DEVELOPMENT TEST INSTANCE
# ============================================================

resource "aws_instance" "development_test" {
  provider = aws.development

  ami           = data.aws_ssm_parameter.development_al2023.value
  instance_type = "t3.micro"
  
  subnet_id                   = aws_subnet.development_private.id
  vpc_security_group_ids      = [aws_security_group.development_workload.id]
  iam_instance_profile        = aws_iam_instance_profile.development_ec2.name
  associate_public_ip_address = false

  tags = {
    Name = "day2-development-test"
  }
}


# ============================================================
# PRODUCTION TEST INSTANCE
# ============================================================

resource "aws_instance" "production_test" {
  provider = aws.production

  ami           = data.aws_ssm_parameter.production_al2023.value
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.production_private.id
  vpc_security_group_ids      = [aws_security_group.production_workload.id]
  iam_instance_profile        = aws_iam_instance_profile.production_ec2.name
  associate_public_ip_address = false

  tags = {
    Name = "day2-production-test"
  }
}