resource "aws_s3_bucket" "wiz_bucket" {
  bucket_prefix = "wiz-unsecure-bucket"
  tags = {
    Name = "wiz-unsecure-bucket"
  }
}

# Public read policy for S3 bucket (security weakness as required)
resource "aws_s3_bucket_public_access_block" "wiz_bucket_pab" {
  bucket = aws_s3_bucket.wiz_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "wiz_bucket_policy" {
  bucket     = aws_s3_bucket.wiz_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.wiz_bucket_pab]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.wiz_bucket.arn}/*"
      },
      {
        Sid       = "PublicListBucket"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:ListBucket"
        Resource  = aws_s3_bucket.wiz_bucket.arn
      }
    ]
  })
}