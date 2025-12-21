# 🚀 Modular Serverless Data Pipeline

## 🏗 System Architecture
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
```  <-- MAKE SURE THESE 3 BACKTICKS ARE HERE

## 🛠 Key Technical Decisions
* **Zero Hardcoding**: All static ARNs were replaced with dynamic Terraform references to ensure 100% portability.
* **Least Privilege Security**: IAM policies are scoped strictly to the specific S3 and DynamoDB resources created in this stack.
* **Modular Design**: Refactored from a monolithic structure to a layered modular architecture for improved scalability.

## 🛠 Technology Stack
* **Infrastructure as Code:** Terraform (HCL)
* **Cloud Provider:** AWS (S3, Lambda, DynamoDB, IAM)
* **Local Development:** LocalStack (Mocking AWS services)
