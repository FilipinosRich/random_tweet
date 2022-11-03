module "base_infra" {
  source                    = "./modules"
  project_name              = "random-tweet"
  lambda_layer_key          = "lambda/pytorch_fn.zip"
  lambda_function_key       = "lambda/random_tweet.zip"
  TWITTER_ACCESS_KEY_ID     = var.TWITTER_ACCESS_KEY_ID
  TWITTER_ACCESS_KEY_SECRET = var.TWITTER_ACCESS_KEY_SECRET
  TWITTER_API_KEY_ID        = var.TWITTER_API_KEY_ID
  TWITTER_API_KEY_SECRET    = var.TWITTER_API_KEY_SECRET
  TWITTER_BEARER_TOKEN      = var.TWITTER_BEARER_TOKEN
  schedule                  = "cron(0 14 * * ? *)"
}