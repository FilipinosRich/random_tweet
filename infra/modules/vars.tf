variable "project_name" {
  description = "Name of the project"
  default     = "random_tweet"
}

variable "lambda_layer_key" {
  description = "S3 key where the lambda layer zip will be stored"
}

variable "lambda_function_key" {
  description = "S3 key where the lambda source code zip will be stored"
}

variable "TWITTER_API_KEY_ID" {
  description = "Twitter API Key"
}

variable "TWITTER_API_KEY_SECRET" {
  description = "Twitter API Key Secret"
}

variable "TWITTER_ACCESS_KEY_ID" {
  description = "Twitter Access Key"
}

variable "TWITTER_ACCESS_KEY_SECRET" {
  description = "Twitter Access Key Secret"
}

variable "TWITTER_BEARER_TOKEN" {
  description = "Twitter Bearer Token"
}

variable "schedule" {
  description = "Cron schedule on which to schedule the lambda"
}