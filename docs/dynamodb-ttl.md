# DynamoDB Optimization: Time to Live (TTL)

In the **Serverless Refactor** project, we utilize Amazon DynamoDB's native **Time to Live (TTL)** feature to automate data retention and optimize operational costs.

## 🛠 Why TTL?
As we refactor toward a serverless architecture, reducing manual maintenance is a priority. TTL allows us to:
* **Reduce Costs:** Automatically purge stale data (like expired sessions or temporary logs) without paying for long-term storage.
* **Zero Overhead:** Deletions are handled by AWS in the background and do not consume Provisioned Write Capacity (WCU).
* **Data Privacy:** Automatically enforce data retention policies.


## 📝 Implementation Details
- **TTL Attribute:** `ExpiresAt`
- **Format:** Unix Epoch Timestamp (Number)
- **Background Process:** DynamoDB scans the `ExpiresAt` attribute and removes items once the current time exceeds the stored timestamp.

## 🚀 Impact on Refactoring
By offloading "cleanup" logic from AWS Lambda to the DynamoDB engine itself, we reduce code complexity, lower Lambda execution time, and ensure our architecture remains lean and scalable.
