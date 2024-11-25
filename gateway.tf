# ## MAIN API GATEWAY unique by product
# resource "aws_apigatewayv2_api" "main_api" {
#   name          = "test-product"
#   protocol_type = "HTTP"
# }

# ## stage aka environment 
# resource "aws_apigatewayv2_stage" "default" {
#   api_id      = aws_apigatewayv2_api.main_api.id
#   name        = "$default"
#   auto_deploy = true
# }

# ## route declaration
# resource "aws_apigatewayv2_route" "main_route" {
#   api_id             = aws_apigatewayv2_api.main_api.id
#   route_key          = "GET /"
#   authorization_type = "JWT"
#   authorizer_id      = aws_apigatewayv2_authorizer.auth0.id
# }

# resource "aws_apigatewayv2_route" "test_route" {
#   api_id             = aws_apigatewayv2_api.main_api.id
#   route_key          = "GET /test"
#   authorization_type = "JWT"
#   authorizer_id      = aws_apigatewayv2_authorizer.auth0.id
#   target             = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
# }

# output "api_endpoint" {
#   value = aws_apigatewayv2_stage.default.invoke_url
# }

# ## authorizer
# variable "auth0_domain" {
#   type        = string
#   default     = "https://dev-njfejmydckdqgtwb.eu.auth0.com/api/v2/"
#   description = "Auth0 domain (e.g., 'your-tenant.auth0.com')"
# }

# variable "auth0_issuer" {
#   type        = string
#   default     = "dev-njfejmydckdqgtwb.eu.auth0.com"
#   description = "Auth0 domain (e.g., 'your-tenant.auth0.com')"
# }

# variable "auth0_audience" {
#   type    = string
#   default = "testaudience"

#   description = "Auth0 API audience identifier"
# }

# resource "aws_apigatewayv2_authorizer" "auth0" {
#   api_id           = aws_apigatewayv2_api.main_api.id
#   authorizer_type  = "JWT"
#   identity_sources = ["$request.header.Authorization"]
#   name             = "auth0-authorizer"

#   jwt_configuration {
#     audience = [var.auth0_audience]
#     issuer   = "https://${var.auth0_issuer}/"
#   }
# }

# # Add the integration
# resource "aws_apigatewayv2_integration" "lambda_integration" {
#   api_id                 = aws_apigatewayv2_api.main_api.id
#   integration_type       = "AWS_PROXY"
#   integration_method     = "POST"
#   integration_uri        = aws_lambda_function.test_lambda.invoke_arn
#   payload_format_version = "2.0"
# }

# # Add permission for API Gateway to invoke Lambda
# resource "aws_lambda_permission" "api_gw" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.test_lambda.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_apigatewayv2_api.main_api.execution_arn}/*/*"
# }



# // NEW TEST WITH MODULE
# module "module_reference_name" {
#   source       = "git::https://github.com/Minitiz/modules-tf.git?ref=api-gateway/v1.0.0"
#   gateway_name = "test-module"
#   routes = [
#     {
#       route_key = "GET /test"
#       target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
#     },
#     {
#       route_key = "GET /test2"
#       target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
#     }
#   ]
# }
