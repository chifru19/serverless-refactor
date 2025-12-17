data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_handler.py"
  output_path = "${path.module}/lambda_handler.zip"
}

resource "aws_lambda_function" "serverless_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = "refactor-lambda-qa"
  role             = "arn:aws:iam::123456789012:role/lambda-role"
  handler          = "lambda_handler.lambda_handler"
  runtime          = "python3.9"
}
