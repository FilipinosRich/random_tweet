resource "aws_lambda_layer_version" "random_tweet_layer" {
  layer_name = "${var.project_name}-lambda-layer-${var.lambda_layer_version}"

  compatible_runtimes      = ["python3.8"]
  compatible_architectures = ["x86_64"]
  s3_bucket                = aws_s3_bucket.random-tweet.id
  s3_key                   = var.lambda_layer_key
  source_code_hash         = filebase64sha256(var.lambda_layer_key)
}

resource "aws_lambda_function" "random_tweet_lambda" {
  # ... other configuration ...
  function_name    = "${var.project_name}-lambda-function"
  s3_bucket        = aws_s3_bucket.random-tweet.id
  s3_key           = var.lambda_function_key
  layers           = [aws_lambda_layer_version.random_tweet_layer.arn]
  source_code_hash = filebase64sha256(var.lambda_function_key)
  ephemeral_storage {
    size = 2048
  }
  memory_size = 2048
  role        = aws_iam_role.random_tweet_role.arn
  runtime     = "python3.8"
  handler     = "lambda_function.lambda_handler"
  timeout     = 60
  environment {
    variables = {
      "API_TOKEN" : var.TWITTER_API_KEY_ID
      "API_TOKEN_SECRET" : var.TWITTER_API_KEY_SECRET
      "ACCESS_TOKEN" : var.TWITTER_ACCESS_KEY_ID
      "ACCESS_TOKEN_SECRET" : var.TWITTER_ACCESS_KEY_SECRET
      "BEARER_TOKEN" : var.TWITTER_BEARER_TOKEN
    }
  }
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

resource "aws_iam_policy" "random_tweet_lambda_access" {
  name        = "${var.project_name}-lambda-access"
  description = "Policy to grant access to the execution role of the Lambda."

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "*"
          ],
          "Effect" : "Allow",
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.random_tweet_role.name
  policy_arn = aws_iam_policy.random_tweet_lambda_access.arn
}