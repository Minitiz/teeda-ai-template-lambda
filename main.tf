provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

provider "random" {}

data "aws_caller_identity" "current_account" {}

data "aws_region" "current_region" {}

resource "random_string" "random" {
  length  = 4
  special = false
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_role" "function_role" {
  assume_role_policy  = data.aws_iam_policy_document.lambda_assume_role_policy.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

# Create the function
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "functions/first-function/src/bin/bootstrap"
  output_path = "functions/first-function/src/bin/lambda.zip"
}


resource "aws_kms_key" "log_group_key" {}

resource "aws_kms_key_policy" "log_group_key_policy" {
  key_id = aws_kms_key.log_group_key.id
  policy = jsonencode({
    Id = "log_group_key_policy"
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current_account.account_id}:root"
        }

        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
      {
        Effect = "Allow",
        Principal = {
          Service : "logs.${data.aws_region.current_region.name}.amazonaws.com"
        },
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        Resource = "*"
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_lambda_function" "test_lambda" {
  function_name    = "HelloFunction-${random_string.random.id}"
  role             = aws_iam_role.function_role.arn
  handler          = "bootstrap"
  runtime          = "provided.al2"
  filename         = "functions/first-function/src/bin/lambda.zip"
  source_code_hash = data.archive_file.lambda.output_base64sha256
}

# Explicitly create the function’s log group to set retention and allow auto-cleanup
resource "aws_cloudwatch_log_group" "lambda_function_log" {
  retention_in_days = 1
  name              = "/aws/lambda/${aws_lambda_function.test_lambda.function_name}"
  kms_key_id        = aws_kms_key.log_group_key.arn
}

# Create an IAM role for the Step Functions state machine
data "aws_iam_policy_document" "state_machine_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_role" "StateMachineRole" {
  name               = "StepFunctions-Terraform-Role-${random_string.random.id}"
  assume_role_policy = data.aws_iam_policy_document.state_machine_assume_role_policy.json
}

data "aws_iam_policy_document" "state_machine_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups"
    ]

    resources = ["${aws_cloudwatch_log_group.MySFNLogGroup.arn}:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = ["${aws_lambda_function.test_lambda.arn}"]
  }

}

# Create an IAM policy for the Step Functions state machine
resource "aws_iam_role_policy" "StateMachinePolicy" {
  role   = aws_iam_role.StateMachineRole.id
  policy = data.aws_iam_policy_document.state_machine_role_policy.json
}

# Create a Log group for the state machine
resource "aws_cloudwatch_log_group" "MySFNLogGroup" {
  name_prefix       = "/aws/vendedlogs/states/MyStateMachine-"
  retention_in_days = 1
  kms_key_id        = aws_kms_key.log_group_key.arn
}
