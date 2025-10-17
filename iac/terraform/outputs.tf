output "api_gateway_url" {
  description = "The base URL for the API Gateway HTTP API."
  value       = aws_apigatewayv2_stage.default_stage.invoke_url
}

output "predict_endpoint" {
  description = "The full URL for the prediction endpoint."
  value       = "${aws_apigatewayv2_stage.default_stage.invoke_url}/predict"
}