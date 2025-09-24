resource "aws_s3_bucket" "wiz_bucket" {
  bucket_prefix = "wiz-unsecure-bucket"
  tags = {
    Name = "wiz-unsecure-bucket"
  }
}
