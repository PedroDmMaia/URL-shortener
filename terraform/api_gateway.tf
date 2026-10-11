resource "aws_apigatewayv2_api" "url_shortener" {
  name          = "url-shortener-api"
  protocol_type = "HTTP"

  route_selection_expression   = "$request.method $request.path"
  api_key_selection_expression = "$request.header.x-api-key"
  ip_address_type              = "ipv4"
  disable_execute_api_endpoint = false
}

resource "aws_apigatewayv2_integration" "create" {
  api_id                 = aws_apigatewayv2_api.url_shortener.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.generate_shortener_url.arn
  integration_method     = "POST"
  payload_format_version = "2.0"
  timeout_milliseconds   = 30000
}

resource "aws_apigatewayv2_integration" "redirect" {
  api_id                 = aws_apigatewayv2_api.url_shortener.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.redirect.arn
  integration_method     = "POST"
  payload_format_version = "2.0"
  timeout_milliseconds   = 30000
}

resource "aws_apigatewayv2_route" "create" {
  api_id    = aws_apigatewayv2_api.url_shortener.id
  route_key = "POST /create"
  target    = "integrations/${aws_apigatewayv2_integration.create.id}"
}

resource "aws_apigatewayv2_route" "redirect" {
  api_id    = aws_apigatewayv2_api.url_shortener.id
  route_key = "GET /{urlCode}"
  target    = "integrations/${aws_apigatewayv2_integration.redirect.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.url_shortener.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    detailed_metrics_enabled = false
    throttling_burst_limit   = 100
    throttling_rate_limit    = 50
  }

  lifecycle {
    ignore_changes = [deployment_id]
  }
}

resource "aws_apigatewayv2_stage" "production" {
  api_id      = aws_apigatewayv2_api.url_shortener.id
  name        = "production"
  auto_deploy = true

  default_route_settings {
    detailed_metrics_enabled = false
    throttling_burst_limit   = 100
    throttling_rate_limit    = 50
  }
}
