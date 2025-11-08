**RDS Oracle with Terraform (Demo)**

This project demonstrates how to deploy Amazon RDS for Oracle SE2 on AWS using Terraform with minimal cost and complexity.Single AZ created in the project, expand multiple AZs in jobs.

#Architecture Overview#

VPC (10.0.0.0/16) with Internet Gateway (IGW) and two public subnets (10.0.0.0/24, 10.0.1.0/24)

RDS Security Group allowing Oracle TCP 1521 access only from your IP

Amazon RDS for Oracle SE2 19c (license-included), db.t3.medium, gp3 20 GiB, Single-AZ, Publicly Accessible

Cost-optimized setup: backups off, enhanced monitoring off, Performance Insights off, deletion protection off, skip final snapshot on