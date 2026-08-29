# ============================================================
# WORKLOAD IAM ROLE
# ============================================================

resource "aws_iam_role" "workload" {
  provider = aws.development

  name               = "Day3WorkloadRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json

  tags = {
    Name = "Day3WorkloadRole"
  }
}


resource "aws_iam_policy" "workload" {
  provider = aws.development

  name   = "Day3WorkloadPolicy"
  policy = data.aws_iam_policy_document.workload.json
}


resource "aws_iam_role_policy_attachment" "workload" {
  provider = aws.development

  role       = aws_iam_role.workload.name
  policy_arn = aws_iam_policy.workload.arn
}


# ============================================================
# SYSTEMS MANAGER PERMISSION
# ============================================================

resource "aws_iam_role_policy_attachment" "ssm" {
  provider = aws.development

  role       = aws_iam_role.workload.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# ============================================================
# EC2 INSTANCE PROFILE
# ============================================================

resource "aws_iam_instance_profile" "workload" {
  provider = aws.development

  name = "Day3WorkloadInstanceProfile"
  role = aws_iam_role.workload.name
}