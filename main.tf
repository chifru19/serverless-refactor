# Set up Terraform configuration
terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider Configuration (CRITICAL FOR LOCALSTACK)
provider "aws" {
  region                      = var.aws_region
  access_key                  = "testing" # LocalStack dummy credentials
  secret_key                  = "testing"
  
  # LOCALSTACK CONNECTION FIXES:
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_force_path_style         = true # Required for LocalStack S3 addressing

  # Force all resources to target the LocalStack endpoint
  endpoints {
    s3          = "http://localhost:4566"
    lambda      = "http://localhost:4566"
    dynamodb    = "http://localhost:4566"
    # Include all services used by the modules
    iam         = "http://localhost:4566"
  }
}

# --- Module and Resource Calls ---

# 1. DynamoDB Table (Defined in dynamodb.tf)
resource "aws_dynamodb_table" "data_table" {
  # All configuration is defined in dynamodb.tf
  # We reference it here to make it available for ARN lookups
  # by the Lambda IAM policy in lambda.tf
  for_each = { main = 1 }
  name     = var.dynamodb_table_name
}

# 2. S3 Bucket and Trigger (Defined in s3.tf)
resource "aws_s3_bucket" "data_bucket" {
  for_each = { main = 1 }
  bucket = var.s3_bucket_name
}

# 3. Lambda Function and Role (Defined in lambda.tf)
resource "aws_lambda_function" "data_processor" {
  for_each = { main = 1 }
  function_name = var.lambda_function_name
}
