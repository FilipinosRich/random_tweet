resource "aws_lambda_layer_version" "random_tweet_layer" {
  layer_name = "${var.project_name}-lambda-layer"

  compatible_runtimes      = ["python3.7"]
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
  runtime     = "python3.7"
  handler     = "lambda_function.lambda_handler"
}

resource "aws_iam_role" "random_tweet_role" {
  name               = "iam_for_lambda"
  assume_role_policy = aws_iam_policy.random_tweet_lambda.policy
}

resource "aws_iam_policy" "random_tweet_lambda" {
  name        = "${var.project_name}-lambda-policy"
  path        = "/"
  description = "Policy for the lambda function for the random tweet project."

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "random_tweet_lambda" {
  role       = aws_iam_role.random_tweet_role.name
  policy_arn = aws_iam_policy.random_tweet_lambda.arn
}