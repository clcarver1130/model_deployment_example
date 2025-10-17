variable "ecr_repository_name" {
  description = "The name for the ECR repository."
  type        = string
  default     = "ml-inference-api-repo"
}

variable "image_uri" {
  description = "ECR image URI for Lambda"
  type        = string
  default     = ""
}

variable "aws_region" {
    description = "The AWS region to deploy resources in."
    type        = string
    default     = "us-east-1"
}

variable "image_tag" {
  description = "The tag of the Docker image in ECR to deploy."
  type        = string
  default     = "latest"
}
