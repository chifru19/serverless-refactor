# 🚀 Modular Serverless Data Pipeline

This project demonstrates a production-grade, event-driven serverless architecture built with Terraform. It has been refactored from a monolithic "flat" structure into a **Layered Modular Architecture** to showcase scalable IaC best practices.

## 🏗 System Architecture

The following diagram illustrates the event-driven flow where an S3 upload triggers a Lambda function to process data and update DynamoDB.

```mermaid
graph TD
    User([User/Client]) -->|Uploads File| S3[S3 Trigger Bucket]
    S3 -->|s3:ObjectCreated| Lambda[Lambda: ServerlessRefactorFunction]
    Lambda -->|Get Object| S3
    Lambda -->|Put Item| Dynamo[(DynamoDB: ServerlessRefactorTable)]

    subgraph "AWS Cloud (eu-central-1)"
    S3
    Lambda
    Dynamo
    end

    subgraph "Security & Logging"
    IAM[IAM Role: Managed ARNs]
    CW[CloudWatch Logs]
    end

    Lambda -.-> IAM
    Lambda -.-> CW
# Technical Architecture & ImprovementsThis project has been refactored from a flat configuration into a Layered Modular Infrastructure, adhering to enterprise-level DevOps standards.### 1. Security & IAM GovernanceZero Hardcoding: Removed all static/placeholder ARNs for IAM roles.Dynamic Referencing: Implemented dynamic resource linking using aws_iam_role.lambda_exec_role.arn to ensure environment portability.Least Privilege Access: Created a scoped IAM policy in iam.tf that strictly limits Lambda permissions to specific S3 GetObject and DynamoDB PutItem actions.### 2. Infrastructure as Code (IaC) StandardsModular Design: Separated core logic into /modules, allowing the infrastructure to be scaled or replicated across environments (QA/Prod) with minimal changes.Automated Provisioning: Configured the full event-driven lifecycle within Terraform, including S3 Bucket Notifications and Lambda permissions.Validation: The entire configuration is verified using terraform validate and terraform init to ensure syntax integrity and provider compatibility.### 3. Resource MapComponentImplementationPurposeStorageaws_s3_bucketSource for event-driven triggers.Databaseaws_dynamodb_tablePersistent storage for processed metadata.Computeaws_lambda_functionServerless execution using Python 3.9 runtime.Securityaws_iam_role_policyFine-grained access control boundary.
