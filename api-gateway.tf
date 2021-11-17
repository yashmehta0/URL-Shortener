resource "aws_api_gateway_rest_api" "api_url_shortener" {
  name = var.api_url_shortener_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
resource "aws_api_gateway_resource" "url_shortener_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_url_shortener.id
  parent_id   = aws_api_gateway_rest_api.api_url_shortener.root_resource_id
  path_part   = "shrink_url"
}
resource "aws_api_gateway_resource" "url_redirect_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_url_shortener.id
  parent_id   = aws_api_gateway_rest_api.api_url_shortener.root_resource_id
  path_part   = "{key}"
}
resource "aws_api_gateway_method" "url_shortener_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_url_shortener.id
  resource_id   = aws_api_gateway_resource.url_shortener_proxy.id
  http_method   = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_method" "url_redirect_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_url_shortener.id
  resource_id   = aws_api_gateway_resource.url_redirect_proxy.id
  http_method   = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "url_shortener_lambda" {
  rest_api_id = aws_api_gateway_rest_api.api_url_shortener.id
  resource_id = aws_api_gateway_method.url_shortener_proxy_method.resource_id
  http_method = aws_api_gateway_method.url_shortener_proxy_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.shortener_lambda.invoke_arn
}
resource "aws_api_gateway_integration" "url_redirect_lambda" {
  rest_api_id = aws_api_gateway_rest_api.api_url_shortener.id
  resource_id = aws_api_gateway_method.url_redirect_proxy_method.resource_id
  http_method = aws_api_gateway_method.url_redirect_proxy_method.http_method
  request_parameters      = {}
  passthrough_behavior    = "NEVER"
  request_templates       = {
    "application/json" = jsonencode(
        {
          Key = "$input.params('key')"
        }
      )
    }

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.redirect_lambda.invoke_arn
}
resource "aws_api_gateway_method_response" "url_shortener_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api_url_shortener.id
  resource_id = aws_api_gateway_method.url_shortener_proxy_method.resource_id
  http_method = aws_api_gateway_method.url_shortener_proxy_method.http_method
  status_code = "200"

  response_models = {
    "application/json" : "Empty"
  }

  depends_on = ["aws_api_gateway_method.url_shortener_proxy_method"]
}
resource "aws_api_gateway_method_response" "url_redirect_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api_url_shortener.id
  resource_id = aws_api_gateway_method.url_redirect_proxy_method.resource_id
  http_method = aws_api_gateway_method.url_redirect_proxy_method.http_method
  status_code = "302"

  response_parameters = {
    "method.response.header.Location" = false
  }  

  depends_on = ["aws_api_gateway_method.url_redirect_proxy_method"]
}
resource "aws_api_gateway_integration_response" "url_shortener_integration_response" {
  depends_on  = [aws_api_gateway_method_response.url_shortener_method_response, aws_api_gateway_integration.url_shortener_lambda]
  rest_api_id = aws_api_gateway_rest_api.api_url_shortener.id
  resource_id = aws_api_gateway_method.url_shortener_proxy_method.resource_id
  http_method = aws_api_gateway_method.url_shortener_proxy_method.http_method
  status_code = aws_api_gateway_method_response.url_shortener_method_response.status_code

  response_templates = {
    "application/json" = ""
  }
}
resource "aws_api_gateway_integration_response" "url_redirect_integration_response" {
  depends_on  = [aws_api_gateway_method_response.url_redirect_method_response, aws_api_gateway_integration.url_redirect_lambda]
  rest_api_id = aws_api_gateway_rest_api.api_url_shortener.id
  resource_id = aws_api_gateway_method.url_redirect_proxy_method.resource_id
  http_method = aws_api_gateway_method.url_redirect_proxy_method.http_method
  status_code = aws_api_gateway_method_response.url_redirect_method_response.status_code

  response_parameters = {
    "method.response.header.Location" = "integration.response.body.Redirect"
  }
}
resource "aws_api_gateway_deployment" "api_url_shortener_deploy" {
  depends_on = [
    aws_api_gateway_integration.url_shortener_lambda,
    aws_api_gateway_integration.url_redirect_lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.api_url_shortener.id
  stage_name  = var.api_stage_name
}
resource "aws_lambda_permission" "api_url_shortener_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.shortener_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api_url_shortener.execution_arn}/*/*"
}
resource "aws_lambda_permission" "api_url_redirect_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.redirect_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api_url_shortener.execution_arn}/*/*"
}
resource "aws_api_gateway_method_settings" "api_url_shortener_settings" {
  rest_api_id = aws_api_gateway_rest_api.api_url_shortener.id
  stage_name  = aws_api_gateway_deployment.api_url_shortener_deploy.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000

  }
}

resource "aws_api_gateway_account" "all" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_role.arn
}