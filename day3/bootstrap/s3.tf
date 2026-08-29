# ============================================================
# TERRAFORM STATE / PIPELINE ARTIFACT BUCKET
# ============================================================

resource "aws_s3_bucket" "day3" {
  bucket = "oluwasanyaogunsakin4999433-day3-tfstate"

  force_destroy = true

  tags = {
    Name = "day3-terraform-state"
  }
}


# ============================================================
# BLOCK ALL PUBLIC ACCESS
# ============================================================

resource "aws_s3_bucket_public_access_block" "day3" {
  bucket = aws_s3_bucket.day3.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}