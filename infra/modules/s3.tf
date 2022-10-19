resource "aws_s3_bucket" "Random-Tweet" {
  bucket = "Random-Tweet-Bucket"

}

resource "aws_kms_key" "Random-Tweet-Key" {
  description             = "This key is used to encrypt bucket objects in the Random-Tweet bucket."
  deletion_window_in_days = 7
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.Random-Tweet.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.Random-Tweet-Key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
