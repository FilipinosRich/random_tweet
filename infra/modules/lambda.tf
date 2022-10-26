resource "aws_lambda_layer_version" "random_tweet_layer" {
  layer_name = "${var.project_name}-lambda-layer"

  compatible_runtimes      = ["python3.8"]
  compatible_architectures = ["x86_64"]
  s3_bucket                = aws_s3_bucket.random-tweet.id
  s3_key                   = var.lambda_layer_key
}

resource "aws_lambda_function" "random_tweet_lambda" {
  # ... other configuration ...
  function_name = "${var.project_name}-lambda-function"
  s3_bucket     = aws_s3_bucket.random-tweet.id
  s3_key        = var.lambda_function_key
  layers        = [aws_lambda_layer_version.random_tweet_layer.arn]
  ephemeral_storage {
    size = 2048
  }
  memory_size = 2048
  role        = aws_iam_role.random_tweet_role.arn
  runtime     = "python3.8"
  handler     = "lambda_function.lambda_handler"
}

resource "aws_iam_role" "random_tweet_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : ""
        }
      ]
    }
  )
}