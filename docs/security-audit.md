# IAM Security Audit Report (Internal)

**Project:** Serverless Refactor  
**Status:** ✅ Compliant  
**Last Review:** 2025-12-17  

## 📑 Audit Summary
This report summarizes the periodic review of access identities and resource-based policies to ensure no "permission creep" has occurred during the refactoring process.

## 🕵️ Access Review
| Identity (Role) | Purpose | Access Level | Status |
| :--- | :--- | :--- | :--- |
| `LambdaS3ProcessorRole` | Processing file uploads | Limited (S3:Read, DDB:Write) | ✅ Validated |
| `AppSyncDataResolver` | UI Data Fetching | Read-Only (DDB:Query) | ✅ Validated |
| `TerraformDeployer` | Infrastructure as Code | Scoped Admin | ✅ Validated |



## 🚨 Security Findings & Remediations
1. **Finding:** Previous developer used `*` for some S3 actions.  
   **Remediation:** Scoped permissions down to the specific `serverless-refactor-uploads` bucket ARN.
2. **Finding:** TTL attribute was missing `dynamodb:DeleteItem` permission check.  
   **Remediation:** Confirmed TTL is an engine-level feature; no explicit Delete permissions are required for the Lambda role, further reducing risk.

## 🔒 Monitoring & Logging
All IAM "Access Denied" events are captured via **AWS CloudTrail** and sent to **Amazon CloudWatch** for real-time alerting.
