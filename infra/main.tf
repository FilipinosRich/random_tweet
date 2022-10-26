module "base_infra" {
  source              = "./modules"
  project_name        = "random-tweet"
  lambda_layer_key    = "lambda/pytorch_fn.zip"
  lambda_function_key = "lambda/lambda_function.zip"
}