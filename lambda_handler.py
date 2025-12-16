import os
import json
import boto3
import uuid

# Initialize DynamoDB client.
# When running locally via LocalStack, the client will automatically use the 
# AWS_ENDPOINT_URL environment variable set in lambda.tf.
dynamodb = boto3.resource('dynamodb', endpoint_url=os.environ.get('AWS_ENDPOINT_URL'))
table_name = os.environ.get('DYNAMODB_TABLE')
table = dynamodb.Table(table_name)

def handler(event, context):
    try:
        print(f"Received event: {json.dumps(event)}")
        
        # Iterate over S3 records to process the files that triggered the Lambda
        for record in event['Records']:
            bucket = record['s3']['bucket']['name']
            key = record['s3']['object']['key']
            record_id = str(uuid.uuid4())

            # Log the key details
            print(f"Processing object s3://{bucket}/{key}")
            
            # Write a processed record to DynamoDB using the Single-Table Design PK/SK
            table.put_item(
                Item={
                    'PK': f'FILE#{record_id}', # Unique ID for Partition Key
                    'SK': f'S3KEY#{key}',      # S3 Object Key for Sort Key
                    'Bucket': bucket,
                    'Status': 'Processed',
                    'Timestamp': context.get_remaining_time_in_millis()
                }
            )
            print(f"Successfully wrote record {record_id} to DynamoDB.")

        return {
            'statusCode': 200,
            'body': json.dumps('Pipeline processing complete')
        }
        
    except Exception as e:
        print(f"Error processing records: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error during Lambda execution: {str(e)}')
        }
