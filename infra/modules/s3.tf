resource "aws_s3_bucket" "random-tweet" {
  bucket = "${var.project_name}-bucket"

}

resource "aws_kms_key" "random-tweet-key" {
  description             = "This key is used to encrypt bucket objects in the Random-Tweet bucket."
  deletion_window_in_days = 7
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.random-tweet.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.random-tweet-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
