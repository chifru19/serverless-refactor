# 🚀 Modular Serverless Data Pipeline (Terraform & LocalStack)

This project demonstrates a professional-grade refactor of an event-driven data pipeline. By transitioning from a monolithic "flat" structure to a **Layered Modular Architecture**, this project showcases scalable IaC best practices.

---

## 🏗️ Architecture Overview

The system utilizes a modular design where the core serverless logic is decoupled from specific environment configurations.

```mermaid
graph LR
    subgraph "IaC Management Layer"
        QA[environments/qa] -- "calls" --> MOD[modules/lambda]
    end

    subgraph "AWS Event-Driven Pipeline"
        S3[S3 Bucket] -- "s3:ObjectCreated" --> Lambda[AWS Lambda]
        Lambda -- "JSON Processing" --> DB[(DynamoDB Table)]
    end

    style Lambda fill:#f96,stroke:#333,stroke-width:2px
    style MOD fill:#e1f5fe,stroke:#01579b
