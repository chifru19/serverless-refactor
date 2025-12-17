# IAM Security & Least Privilege Strategy

This document outlines the security posture for the **Serverless Refactor** project, focusing on the Identity and Access Management (IAM) policies that govern our Lambda functions and database access.

## 🔐 Principle of Least Privilege
Instead of using broad administrative permissions, we use "Fine-Grained" IAM policies. Each service is granted only the minimum permissions required to perform its specific task.



## 🛠 Lambda Execution Role
Our core Lambda function uses a custom execution role with the following scoped permissions:

### 1. DynamoDB Access
The function is restricted to specific actions on our table ARN, preventing it from accessing or deleting other database resources.
* **Actions:** `dynamodb:PutItem`, `dynamodb:GetItem`, `dynamodb:UpdateItem`
* **Resource:** `arn:aws:dynamodb:region:account-id:table/MyTable`

### 2. S3 Bucket Access
Permissions are limited to the specific bucket used for our serverless event triggers.
* **Actions:** `s3:GetObject`
* **Resource:** `arn:aws:s3:::my-trigger-bucket/*`

## 🛡️ Security Best Practices Implemented
* **No Inline Policies:** We use managed or customer-managed policies for better auditability.
* **Resource-Level Restrictions:** Every policy statement includes a specific `Resource` ARN rather than using wildcards (`*`).
* **CloudWatch Logging:** The execution role includes `logs:CreateLogGroup` and `logs:PutLogEvents` to ensure full traceability of all actions.
