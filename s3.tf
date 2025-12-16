# S3 Bucket Definition
resource "aws_s3_bucket" "data_bucket" {
  bucket = var.s3_bucket_name
  
  tags = {
    Name = var.s3_bucket_name
  }
}

# Granting S3 permission to invoke the Lambda
# This is required so S3 is allowed to call the Lambda function
resource "aws_lambda_permission" "allow_s3_invocation" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.data_bucket.arn
}

# S3 Notification (THE INVOCATION FIX - Defining the Trigger)
resource "aws_s3_bucket_notification" "s3_trigger" {
  bucket = aws_s3_bucket.data_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.data_processor.arn
    events              = ["s3:ObjectCreated:*"] # Trigger on file upload
  }
}
