# Serverless Architecture Refactor

This repository contains a refactored serverless data processing pipeline. The project has been moved from a flat configuration into a **Modular Infrastructure as Code (IaC)** structure using Terraform, focusing on security, scalability, and zero-touch automation.

---

## ## 1. System Architecture

The following diagram illustrates the event-driven flow where an S3 upload triggers a Lambda function to process data and update DynamoDB.

```mermaid
graph TD
    User([User/Client]) -->|Uploads File| S3[S3 Trigger Bucket]
    S3 -->|s3:ObjectCreated| Lambda[Lambda: ServerlessProcessor]
    Lambda -->|Get Object| S3
    Lambda -->|Put Item| Dynamo[(DynamoDB: ServerlessTable)]

    subgraph "AWS Cloud (eu-central-1)"
        S3
        Lambda
        Dynamo
    end

    subgraph "Security & Governance"
        IAM[IAM Role: Dynamic ARNs]
        CW[CloudWatch Logs]
    end

    Lambda -.-> IAM
    Lambda -.-> CW
