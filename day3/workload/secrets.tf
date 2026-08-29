# ============================================================
# SECRETS MANAGER SECRET
# ============================================================

resource "aws_secretsmanager_secret" "app" {
  provider = aws.development

  name                    = "day3/app/database"
  description             = "Day 3 application database credentials"
  recovery_window_in_days = 0

  kms_key_id = aws_kms_key.day3.arn

  tags = {
    Name = "day3-app-database-secret"
  }
}


# ============================================================
# GENERATE DATABASE PASSWORD
# ============================================================

resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!#$%&*+-=?@^_"
}


# ============================================================
# STORE DATABASE CREDENTIALS
# ============================================================

resource "aws_secretsmanager_secret_version" "app" {
  provider = aws.development

  secret_id = aws_secretsmanager_secret.app.id

  secret_string = jsonencode({
    username = "appuser"
    password = random_password.db.result
  })
}