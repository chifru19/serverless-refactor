# DynamoDB Optimization: Global Secondary Indexes (GSI)

In this project, we utilize **Global Secondary Indexes (GSI)** to ensure high-performance data retrieval across multiple access patterns without resorting to expensive table scans.

## 🔍 Why GSI?
While our Primary Key (Partition Key) is optimized for specific item lookups, we often need to query data using different attributes (e.g., searching by `Status`, `Category`, or `Timestamp`).


## 🚀 Key Benefits
* **Performance at Scale:** GSIs allow us to perform targeted queries on non-key attributes with single-digit millisecond latency.
* **Cost Efficiency:** By avoiding `Scan` operations, we significantly reduce the Read Capacity Units (RCUs) consumed by the application.
* **Separation of Concerns:** We can project only the necessary attributes into the index, further optimizing storage and throughput costs.

## 🛠 Implementation Strategy
- **Index Name:** `StatusIndex` (Example)
- **Partition Key:** `Status`
- **Projection:** `ALL` (or specific attributes required by the UI)
