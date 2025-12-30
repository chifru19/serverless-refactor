# --- 1. PROVIDER ---
provider "aws" {
  region = "eu-central-1"
}

# --- 2. IAM: THE ROLE ---
resource "aws_iam_role" "lambda_exec_role" {
  name = "serverless_refactor_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# --- 3. IAM: THE POLICIES (ROMAN'S REVIEW: NO HARDCODING) ---
resource "aws_iam_role_policy" "lambda_permissions" {
  name = "lambda_s3_dynamo_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem"]
        Resource = aws_dynamodb_table.serverless_table.arn # AUTOMATED
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.trigger_bucket.arn}/*" # AUTOMATED
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# --- 4. RESOURCES: S3 & DYNAMODB ---
resource "aws_s3_bucket" "trigger_bucket" {
  bucket = "frank-fru-serverless-2025"
}

resource "aws_dynamodb_table" "serverless_table" {
  name           = "ServerlessRefactorTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PK"
  range_key      = "SK"

  # Corrected Attribute Block Syntax
  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }
}

# --- 5. LAMBDA FUNCTION (THE CORE LOGIC) ---
resource "aws_lambda_function" "refactor_lambda" {
  function_name = "ServerlessProcessor"
  role          = aws_iam_role.lambda_exec_role.arn # DYNAMIC REFERENCE
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  # Point this to your existing zip or folder
  filename      = "lambda_function.zip" 
}

# --- 6. S3 TRIGGER (AUTOMATION) ---
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.refactor_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.trigger_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.trigger_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.refactor_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_bucket]
}
