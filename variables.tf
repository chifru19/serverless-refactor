variable "aws_region" {
  description = "The AWS region to deploy resources (e.g., us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket (must be globally unique in AWS, but LocalStack allows simple names)"
  type        = string
  default     = "localstack-modular-trigger-bucket"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
  default     = "ServerlessDataPipelineTable"
}

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "DataProcessorFunction"
}
