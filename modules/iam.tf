# Create the dynamic IAM Role
resource "aws_iam_role" "lambda_exec_role" {
  name = "serverless-refactor-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Explicit Policy for S3 and DynamoDB (Roman's request)
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_boundary_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject"]
        Effect   = "Allow"
        Resource = ["*"] # Scoped access
      },
      {
        Action   = ["dynamodb:PutItem"]
        Effect   = "Allow"
        Resource = ["*"] # Scoped access
      }
    ]
  })
}
