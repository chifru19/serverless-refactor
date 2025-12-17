# --- 1. Terraform & Provider Configuration ---
terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = "testing"
  secret_key = "testing"

  # LocalStack Connectivity Fixes
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  
  # Updated for AWS Provider v5.x
  s3_use_path_style           = true 

  endpoints {
    s3       = "http://localhost:4566"
    lambda   = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
    iam      = "http://localhost:4566"
  }
}

# --- 2. Optimized DynamoDB Table ---
resource "aws_dynamodb_table" "data_table" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PK"
  range_key      = "SK"

  attribute { name = "PK";     type = "S" }
  attribute { name = "SK";     type = "S" }
  attribute { name = "Status"; type = "S" }

  # Performance: Global Secondary Index for status-based queries
  global_secondary_index {
    name               = "StatusIndex"
    hash_key           = "Status"
    projection_type    = "ALL"
  }

  # Data Lifecycle: Automated expiration
  ttl {
    attribute_name = "ExpiresAt"
    enabled        = true
  }

  tags = {
    Environment = "Dev"
    Project     = "Serverless-Refactor"
  }
}

# --- 3. IAM Security (Principle of Least Privilege) ---
resource "aws_iam_role" "lambda_exec_role" {
  name = "serverless_refactor_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_scoped_policy" {
  name = "lambda_scoped_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query"
        ]
        # Scoped specifically to our table ARN
        Resource = aws_dynamodb_table.data_table.arn
      },
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# --- 4. S3 Bucket & Lambda Function ---
resource "aws_s3_bucket" "data_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_lambda_function" "data_processor" {
  filename      = "lambda_function.zip"
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.9"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.data_table.name
    }
  }
} 
