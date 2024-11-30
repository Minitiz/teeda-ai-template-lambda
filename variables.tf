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

variable "auth0_issuer" {
  type        = string
  default     = "https://dev-njfejmydckdqgtwb.eu.auth0.com"
  description = "Auth0 domain (e.g., 'your-tenant.auth0.com')"
}

variable "auth0_audience" {
  type        = string
  default     = "testaudience"
  description = "Auth0 API audience identifier"
}
