provider "aws" {
  region = var.aws_region_name
}

resource "aws_lambda_function" "shortener_lambda" {
  filename      = "packages/shortener.zip"
  function_name = var.shortener_lambda_name
  role          = aws_iam_role.mapper_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.7"
  timeout       = var.shortener_timeout_value

  environment {
    variables = {
      S3_BUCKET       = var.mapper_bucket_name
    }
  }
}

resource "aws_lambda_function" "redirect_lambda" {
  filename      = "packages/redirect.zip"
  function_name = var.redirect_lambda_name
  role          = aws_iam_role.mapper_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.7"
  timeout       = var.redirect_timeout_value

  environment {
    variables = {
      S3_BUCKET       = var.mapper_bucket_name
    }
  }
}