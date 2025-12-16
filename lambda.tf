# 1. IAM Role for Lambda (Execution Role)
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-s3-dynamo-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# 2. IAM Policy (LEAST PRIVILEGE IMPLEMENTED)
resource "aws_iam_role_policy" "lambda_permissions" {
  name = "lambda-s3-dynamo-permissions"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # CloudWatch Logs (Standard for Lambda)
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        # Standard ARN pattern for logs:
        Resource = "arn:aws:logs:*:*:*" 
      },
      # DynamoDB Access (FIX: Restricted to our table ARN)
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:UpdateItem"]
        Resource = aws_dynamodb_table.data_table.arn # <-- Specific Table ARN Reference
      },
      # S3 Read Access (FIX: Restricted to reading objects from our bucket)
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.data_bucket.arn}/*" # Read objects inside the specific bucket
      }
    ]
  })
}

# 3. The Lambda Function Definition
resource "aws_lambda_function" "data_processor" {
  filename         = "lambda_handler.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_handler.handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("lambda_handler.zip") # This file is created before apply
  
  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.data_table.name
      # CRITICAL for LocalStack: Overrides the AWS endpoint for the Python SDK
      AWS_ENDPOINT_URL = "http://localhost:4566"
    }
  }
}
