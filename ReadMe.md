**RDS Oracle with Terraform (Demo)**

This repository demonstrates a complete end-to-end workflow for automating, initializing, and optimizing an Oracle 19c RDS instance on AWS using Terraform, then connecting to it via SQL Developer for schema creation, data loading, performance testing, and tuning.
It covers both:

Layer A — AWS Management: Infrastructure, monitoring, scaling, and recovery.

Layer B — Database Optimization: SQL Developer, AWR, and benchmark analysis.

## 🧭 Architecture Diagram

[Internet]
│
▼
┌──────────────┐
│ Internet GW │
└──────┬───────┘
│
┌──────▼──────────────┐
│ VPC (10.0.0.0/16) │
│ ├─ Public Subnets │
│ ├─ Security Group → allow TCP 1521 from my_ip_cidr │
│ └─ RDS Oracle SE2 (19c) │
│ ├─ Terraform provisioned │
│ ├─ CloudWatch / PI monitored │
│ └─ SQL Developer connected │
└────────────────────────────────────┘

## Layer A

|  **ID** | **Scenario**                          | **Common Tools / Interface**      | **Description**                                                                         |
| :-----: | ------------------------------------- | --------------------------------- | --------------------------------------------------------------------------------------- |
|  **A1** | Instance Scaling (Performance Tuning) | AWS Console / CLI / Terraform     | Adjust instance class, CPU, memory, and storage configuration; test scaling operations. |
|  **A2** | Storage Management                    | AWS Console / CLI                 | Resize EBS volumes, enable auto-scaling, and manage IOPS.                               |
|  **A3** | Monitoring & Performance Insights     | CloudWatch / Performance Insights | Analyze CPU, memory, I/O latency, and active sessions for Oracle workloads.             |
|  **A4** | Backup & Restore                      | AWS Console / CLI / Lambda        | Manage snapshots, automate backups, and test recovery workflows.                        |
|  **A5** | Cost Optimization & Scheduling        | AWS Console / Terraform           | Automate instance start/stop, tune encryption, and control KMS key usage.               |
|  **A6** | Log Management (RDS Logs)             | AWS Console / CloudWatch Logs     | Review alert, trace, and audit logs for database health diagnostics.                    |
|  **A7** | Network & Security Configuration      | AWS Console / Terraform           | Configure VPCs, subnets, security groups, IAM roles, and KMS encryption.                |
|  **A8** | Cost Reporting & Budgets              | AWS Cost Explorer / Budgets       | Track spending, forecast usage, and set budget alerts.                                  |
|  **A9** | Automation & Event Rules              | Lambda / EventBridge / CLI        | Automate backup or scale events through triggers and schedules.                         |
| **A10** | Disaster Recovery Testing             | AWS Console / CloudFormation      | Simulate failover, cross-region replication, and recovery scenarios.                    |
| **A11** | Security & Audit                      | CloudTrail / CloudWatch Logs      | Review API calls, user activity, and compliance events.                                 |

## Layer B

| **ID** | **Scenario**                    | **Tools / Interface**             | **Description**                                                                    |
| :----: | ------------------------------- | --------------------------------- | ---------------------------------------------------------------------------------- |
| **B1** | Account & Permission Management | SQL Developer / SQL*Plus          | Create database users, assign roles, and implement least-privilege access control. |
| **B2** | SQL Performance Analysis        | SQL Developer / AWR / SQL*Plus    | Capture execution plans, analyze CPU/IO usage, and optimize inefficient queries.   |
| **B3** | Benchmark Testing               | Sysbench / HammerDB / SQL Scripts | Run stress tests, measure TPS, latency, and validate tuning improvements.          |

## Workflow Summary

1️⃣ Provisioning:
Use Terraform (main.tf) to deploy VPC, security groups, and RDS Oracle 19c SE2.

2️⃣ Connection:
Connect via SQL Developer using the RDS endpoint and admin credentials.

3️⃣ Data Initialization:
Run scripts to create schemas and load synthetic data for lab experiments.

4️⃣ Optimization:
Perform query tuning, indexing, and statistics refreshes (AWR/SQL Plan comparison).

5️⃣ Monitoring:
Use CloudWatch and Performance Insights to observe performance, CPU, and IO behavior.

6️⃣ Tear-down:
Execute terraform destroy to remove all resources safely after testing.
