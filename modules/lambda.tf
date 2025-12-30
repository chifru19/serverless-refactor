# 1. Zip the Python code (Zero-Touch Pipeline)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function" # Ensure your python file is in this folder
  output_path = "${path.module}/lambda_function_payload.zip"
}

# 2. Define the Lambda Function
resource "aws_lambda_function" "process_data" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "serverless-refactor-processor"
  
  # CRITICAL: Dynamic reference to the IAM Role (Roman's Point 1)
  role          = aws_iam_role.lambda_exec_role.arn
  
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      ENV = "qa"
    }
  }
}

# 3. S3 Bucket Notification (Trigger)
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.s3_bucket_name # Use a variable here to stay modular

  lambda_function {
    lambda_function_arn = aws_lambda_function.process_data.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

# 4. Permission for S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_data.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.s3_bucket_name}"
}
