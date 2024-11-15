variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "functions/first-function/src/bin/bootstrap"
  output_path = "functions/first-function/src/bin/lambda.zip"
}
