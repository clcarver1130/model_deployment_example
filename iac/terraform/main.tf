# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "my-terraform-state-68c02903"
    key    = "terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region     = "us-east-1"
}

# --- 1. ECR Repository for Docker Image ---
resource "aws_ecr_repository" "ml_inference_repo" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# --- 2. IAM Role and Policy for Lambda ---
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-ml-inference-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name        = "lambda-ml-inference-logging-policy"
  description = "IAM policy for logging from a lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}


resource "aws_iam_role_policy_attachment" "lambda_ecr_read" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


# --- 3. AWS Lambda Function ---
resource "aws_lambda_function" "ml_inference_lambda" {

  function_name = "MLInferenceAPI"
  role          = aws_iam_role.lambda_exec_role.arn
  image_uri     = "${aws_ecr_repository.ml_inference_repo.repository_url}:${var.image_tag}"
  package_type  = "Image"
  memory_size   = 128
  timeout       = 30
}


# --- 4. API Gateway Setup ---
resource "aws_apigatewayv2_api" "http_api" {
  name          = "MLInferenceHttpApi"
  protocol_type = "HTTP" # Use HTTP API for simplicity and lower cost
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.ml_inference_lambda.invoke_arn
  payload_format_version = "2.0" # Required for modern Lambda integrations
}

resource "aws_apigatewayv2_route" "api_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /predict" # Define your API path
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# --- 5. Grant API Gateway permission to invoke Lambda ---
resource "aws_lambda_permission" "apigw_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ml_inference_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The source_arn must refer to the specific route and API.
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# --- Outputs ---
output "api_invoke_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}
