## MAIN API GATEWAY unique by product
resource "aws_apigatewayv2_api" "main_api" {
  name          = "test-product"
  protocol_type = "HTTP"
}

## stage aka environment 
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main_api.id
  name        = "$default"
  auto_deploy = true
}

## route declaration
resource "aws_apigatewayv2_route" "main_route" {
  api_id             = aws_apigatewayv2_api.main_api.id
  route_key          = "GET /"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.auth0.id
}

resource "aws_apigatewayv2_route" "test_route" {
  api_id             = aws_apigatewayv2_api.main_api.id
  route_key          = "GET /test"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.auth0.id
}


output "api_endpoint" {
  value = aws_apigatewayv2_stage.default.invoke_url
}

## authorizer
variable "auth0_domain" {
  type        = string
  default     = "https://dev-njfejmydckdqgtwb.eu.auth0.com/api/v2/"
  description = "Auth0 domain (e.g., 'your-tenant.auth0.com')"
}

variable "auth0_issuer" {
  type        = string
  default     = "dev-njfejmydckdqgtwb.eu.auth0.com"
  description = "Auth0 domain (e.g., 'your-tenant.auth0.com')"
}

variable "auth0_audience" {
  type    = string
  default = "testaudience"

  description = "Auth0 API audience identifier"
}

resource "aws_apigatewayv2_authorizer" "auth0" {
  api_id           = aws_apigatewayv2_api.main_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "auth0-authorizer"

  jwt_configuration {
    audience = [var.auth0_audience]
    issuer   = "https://${var.auth0_issuer}/"
  }
}
