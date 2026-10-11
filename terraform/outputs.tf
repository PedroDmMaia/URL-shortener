output "api_endpoint" {
  description = "URL base da HTTP API."
  value       = aws_apigatewayv2_api.url_shortener.api_endpoint
}

output "create_url" {
  description = "Rota que gera o código curto."
  value       = "${aws_apigatewayv2_api.url_shortener.api_endpoint}/create"
}

output "redirect_url_template" {
  description = "URL base para redirecionar um código curto."
  value       = "${aws_apigatewayv2_api.url_shortener.api_endpoint}/<code>"
}

output "bucket_name" {
  description = "Bucket onde os JSON das URLs ficam gravados."
  value       = aws_s3_bucket.url_storage.bucket
}
