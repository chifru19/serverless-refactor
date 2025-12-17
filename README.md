# 🚀 Conceptual MVP: Modular Serverless Data Pipeline (Terraform & LocalStack)

This project demonstrates the **refactoring and deployment of a modular Serverless data processing pipeline** using **Terraform** and the local cloud environment, **LocalStack**.

The primary goal was to transform a monolithic Terraform configuration into a robust, reusable module while simultaneously solving complex environmental and authentication challenges inherent to using Infrastructure as Code (IaC) with local testing tools.

---

## 🔑 Key Skills Demonstrated

* **Infrastructure as Code (IaC):** Modular design and deployment using Terraform best practices.
* **DevOps/Testing:** Utilizing **LocalStack** to emulate AWS services (S3, Lambda, DynamoDB, IAM) for cost-effective, local testing.
* **Cloud Architecture:** Provisioning an event-driven serverless pipeline: **S3 → Lambda → DynamoDB**. 
* **Troubleshooting:** Advanced resolution of authentication (`InvalidAccessKeyId`) and networking (`Connection Refused`) errors in a Dockerized environment.

---

## ☁️ Architecture & Components

This pipeline is designed to ingest data, process it via a function, and store the result in a NoSQL database.

| Component | Resource | Purpose |
| :--- | :--- | :--- |
| **Data Ingestion** | `aws_s3_bucket` | Stores incoming data that triggers the pipeline (named `localstack-modular-trigger-bucket`). |
| **Compute** | `aws_lambda_function` | Runs the data processing logic (e.g., Python handler). |
| **Data Storage** | `aws_dynamodb_table` | Stores and manages the processed data for fast, low-latency access. |
| **Trigger** | `aws_s3_bucket_notification` | Configures the S3 bucket to invoke the Lambda function upon a new object creation (`s3:ObjectCreated:*`). |
| **Security** | `aws_iam_role` | Grants the Lambda function the minimum necessary permissions to execute, write logs, and interact with the DynamoDB table (see **Least Privilege** section below). |

---

## 💡 Code and Design Solutions

### 1. DynamoDB Data Model Design (Single-Table Key Abstraction)

The DynamoDB table is defined with abstract key names (`PK` for Partition Key and `SK` for Sort Key).

* **Rationale:** This design is intentional, demonstrating the **Single-Table Design** pattern. This approach allows the table to store multiple types of entities (e.g., Users, Orders, Sessions) in a single table, optimizing for cost efficiency, query patterns, and application scalability, as opposed to using a separate table for every entity type.

### 2. Security: Principle of Least Privilege (Implemented Fix)

The Lambda IAM policy has been refactored to grant permissions only to the specific DynamoDB table and S3 bucket, restricting actions to necessary operations (`dynamodb:PutItem`, `s3:GetObject`). This demonstrates adherence to the **Principle of Least Privilege**.

### 3. Lambda Invocation Source (Context)

The Lambda function is explicitly triggered by the `aws_s3_bucket_notification` resource upon a file upload. This resource clearly defines the event-driven relationship between S3 and the Compute layer.

---

## ⚙️ Technical Challenge & Solution (Proof of Skill)

The core technical achievement was successfully stabilizing the environment by resolving recurrent integration errors between the Terraform AWS Provider and the LocalStack Docker container.

* **Errors Encountered:** `API error InvalidAccessKeyId` and `Error: connect: connection refused`.
* **Solution Implemented:** Required bypassing the AWS provider's default behavior and strictly synchronizing the shell environment by using:
    * `skip_credentials_validation = true` in the provider block.
    * Explicitly exporting `AWS_ENDPOINT_URL="http://localhost:4566"` to force the provider to target the LocalStack service.
## 📖 Advanced Architecture Documentation
- [Automated Data Lifecycle (TTL)](./docs/dynamodb-ttl.md)
- [High-Performance Querying (GSI)](./docs/dynamodb-gsi.md)
---
IAM Security & Least Privilege
IAM Security Audit Report

## 🚀 How to Deploy & Verify

### Prerequisites

* Terraform CLI
* Docker Desktop (must be running)
* AWS CLI (for local testing commands)

### Deployment Steps

1.  **Start LocalStack Server:**
    ```bash
    docker run --rm -it -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack
    ```
    *(Wait for the logs to show `Ready.`)*

2.  **Configure Environment (CRITICAL for LocalStack):**
    ```bash
    export AWS_ACCESS_KEY_ID="testing"
    export AWS_SECRET_ACCESS_KEY="testing"
    export AWS_ENDPOINT_URL="http://localhost:4566"
    ```

3.  **Initialize and Apply:**
    ```bash
    # Prepare the zip file for the Lambda function
    zip lambda_handler.zip lambda_handler.py

    # Initialize Terraform
    terraform init -reconfigure
    
    # Apply Infrastructure
    terraform apply
    ```

### Verification (Test the Trigger)

Verify the S3 → Lambda trigger by uploading a test file using the configured LocalStack endpoint:

```bash
echo "Test data for pipeline" > test-data.txt
aws s3 cp test-data.txt s3://[YOUR-BUCKET-NAME] --endpoint-url=http://localhost:4566
