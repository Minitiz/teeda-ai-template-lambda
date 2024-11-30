provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

module "lambda" {
  source = "git::https://github.com/Minitiz/modules-tf.git?ref=lambda/v1.0.1"

  lambda_name          = "test-module"
  lambda_runtime       = "provided.al2"
  lambda_architectures = ["arm64"]
  source_file          = "functions/first-function/src/bin/bootstrap"
  output_path          = "functions/first-function/src/bin/lambda.zip"
}

module "api-gateway" {
  source       = "git::https://github.com/Minitiz/modules-tf.git?ref=api-gateway/v1.1.0"
  gateway_name = "test-module"
  routes = [
    "GET /test",
    "GET /test2"
  ]
  lambda_invoke_arn = module.lambda.lambda_invoke_arn
  function_name     = module.lambda.lambda_function_name
  auth0_issuer      = var.auth0_issuer
  auth0_audience    = var.auth0_audience
}
