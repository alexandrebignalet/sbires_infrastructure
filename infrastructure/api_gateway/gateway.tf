resource "aws_api_gateway_rest_api" "main" {
  name        = "sbires-api-${var.environment}"
  description = "Sbires ${var.environment} API"
}
