# ============================================================
# DAY 3 VPC
# ============================================================

resource "aws_vpc" "day3" {
  provider = aws.development

  cidr_block           = "10.40.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "day3-vpc"
  }
}


# ============================================================
# DAY 3 SUBNET
# ============================================================

resource "aws_subnet" "day3_public" {
  provider = aws.development

  vpc_id                  = aws_vpc.day3.id
  cidr_block              = "10.40.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "day3-public-subnet"
  }
}


# ============================================================
# INTERNET GATEWAY
# ============================================================

resource "aws_internet_gateway" "day3" {
  provider = aws.development

  vpc_id = aws_vpc.day3.id

  tags = {
    Name = "day3-igw"
  }
}


# ============================================================
# PUBLIC ROUTE TABLE
# ============================================================

resource "aws_route_table" "day3_public" {
  provider = aws.development

  vpc_id = aws_vpc.day3.id

  tags = {
    Name = "day3-public-rt"
  }
}


resource "aws_route" "day3_internet" {
  provider = aws.development

  route_table_id         = aws_route_table.day3_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.day3.id
}


resource "aws_route_table_association" "day3_public" {
  provider = aws.development

  subnet_id      = aws_subnet.day3_public.id
  route_table_id = aws_route_table.day3_public.id
}


# ============================================================
# WORKLOAD SECURITY GROUP
# ============================================================

resource "aws_security_group" "day3_workload" {
  provider = aws.development

  name        = "day3-workload-sg"
  description = "Day 3 workload security group"
  vpc_id      = aws_vpc.day3.id

  tags = {
    Name = "day3-workload-sg"
  }
}


# No inbound rules.
# We will manage the EC2 through Systems Manager.


resource "aws_vpc_security_group_egress_rule" "day3_https" {
  provider = aws.development

  security_group_id = aws_security_group.day3_workload.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "Allow outbound HTTPS to AWS services"
}


# ============================================================
# AMAZON LINUX 2023 AMI
# ============================================================

data "aws_ssm_parameter" "al2023" {
  provider = aws.development

  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}


# ============================================================
# DAY 3 EC2 WORKLOAD
# ============================================================

resource "aws_instance" "workload" {
  provider = aws.development

  ami           = data.aws_ssm_parameter.al2023.value
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.day3_public.id
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.day3_workload.id
  ]

  iam_instance_profile = aws_iam_instance_profile.workload.name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "day3-workload"
  }
}