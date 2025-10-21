#!/bin/bash

set -e

# Variables (edit as needed)
AWS_REGION="us-east-1"
RANDOM_SUFFIX=$(uuidgen | tr '[:upper:]' '[:lower:]' | cut -d'-' -f1)
BUCKET_NAME="my-terraform-state-$RANDOM_SUFFIX"
AWS_PROFILE="personal"

echo "Creating S3 bucket: $BUCKET_NAME"
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" --profile "$AWS_PROFILE"

echo "Done! Add this backend block to your main.tf:"
cat <<EOF

terraform {
  backend "s3" {
    bucket = "$BUCKET_NAME"
    key    = "terraform.tfstate"
    region = "$AWS_REGION"
    encrypt = true
  }
}
EOF
