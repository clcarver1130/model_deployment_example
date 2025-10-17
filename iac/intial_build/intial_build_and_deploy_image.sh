#!/bin/bash

# Used only during the initial creation of the infrastructure to build and push the Docker image. Github Actions will handle the process moving forward

# Variables
AWS_REGION="us-east-1" # Replace with your desired AWS Region
AWS_ACCOUNT_ID="396577395766" # Replace with your AWS Account ID
REPOSITORY_NAME="ml-inference-api-repo" # Must match the ECR repository name in your Terraform configuration
IMAGE_TAG="latest"
profile_name="personal" # Change this to your AWS CLI profile name

# Build the Docker image
# The --provenance=false flag is used if you are running on a Machine with Apple Silicon (M1/M2) to avoid issues with provenance data
docker build --platform linux/amd64 --provenance=false -t ${REPOSITORY_NAME}:${IMAGE_TAG} -f Dockerfile_placeholder .

# Authenticate Docker to the ECR registry
aws ecr --profile ${profile_name} get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Tag the Docker image
docker tag ${REPOSITORY_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY_NAME}:${IMAGE_TAG}

# Push the Docker image to ECR
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY_NAME}:${IMAGE_TAG}
