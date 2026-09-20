# ☁️ SDG Wallet — AWS Serverless Cloud Architecture

This directory contains the production-ready AWS Serverless architecture definition and Lambda handlers for the **SDG Wallet** backend.

---

## 🏗️ Architecture Overview

The backend uses a fully serverless, pay-per-request architecture on AWS:

1. **Amazon API Gateway (HTTP API)**: High-performance, low-latency REST endpoints for iOS mobile clients and coordinator web portals.
2. **AWS Lambda (Node.js 20.x)**:
   * `presign.js`: Generates pre-signed S3 `PUT` URLs so mobile clients upload evidence photos directly to S3.
   * `contributions.js`: Handles contribution creation, retrieval, and status filtering with Amazon DynamoDB.
   * `verify.js`: Processes coordinator verification decisions, fine-tunes quantitative metrics, and records immutable audit timestamps.
   * `impact.js`: Aggregates verified sustainability metrics across the UN 5 Pillars (*People, Planet, Prosperity, Peace, Partnership*).
3. **Amazon S3 (`sdg-wallet-evidence-*`)**: Secure object storage for photo proofs with client-side SHA-256 tamper-evident integrity verification.
4. **Amazon DynamoDB (`SDGContributions`)**: Fully managed NoSQL database acting as the audited ledger of all sustainability contributions.

---

## 🚀 Deployment Instructions

### Prerequisites
* [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate IAM permissions (`aws configure`).
* [AWS SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html).

### 1. Build and Deploy with AWS SAM
```bash
cd aws

# Build Lambda dependencies
sam build

# Deploy to your AWS Account
sam deploy --guided
```

During the guided deployment prompt:
* **Stack Name**: `sdg-wallet-backend`
* **AWS Region**: `us-east-1` (or your preferred region)
* **Confirm changes before deploy**: `Y`
* **Allow SAM CLI to create IAM roles with the required permissions**: `Y`

### 2. Connect the iOS App & Web Portal
Upon completion, SAM outputs your live HTTP API URL:
```
HttpApiUrl = https://<api-id>.execute-api.us-east-1.amazonaws.com
```

* **In the iOS App**: Set the `AWS_API_GATEWAY_URL` in `UserDefaults` or update `APIService.swift`.
* **In the Coordinator Portal**: Set the `API_BASE_URL` environment variable or point `fetch` calls to your API Gateway URL.
