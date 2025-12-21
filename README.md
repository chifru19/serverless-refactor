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
## 🛠 Technology Stack
* **Infrastructure as Code:** Terraform (HCL)
* **Cloud Provider:** AWS (S3, Lambda, DynamoDB, IAM)
* **Local Development:** LocalStack (Mocking AWS services)
* **DevOps Tools:** AWS CLI, GitHub
* **Language:** Python (Lambda Logic)
