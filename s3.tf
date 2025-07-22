resource "aws_s3_bucket" "b" {
  bucket = "mehvish-bt1"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "S3Test"
    Environment = "QA"
  }
}