# 🌿 SDG Wallet — Campus Sustainability Coordinator Web Portal

A dedicated administrative web portal for **Campus Sustainability Coordinators** to review, audit, verify, and communicate with students on real-world sustainability contributions.

> **Integrity Standard**: Designed to reduce greenwashing through human verification, tamper-evident integrity verification, and immutable audit trails.

---

## 🧭 Environments & Modes

This project supports two operational environments:

| Mode | Target Backend | Use Case |
| :--- | :--- | :--- |
| **Local Development / Mock Mode** | `http://localhost:3001` (Node.js Express) | Zero-cloud-cost local testing, UI prototyping, and offline development. |
| **Live AWS Production Mode** | Amazon API Gateway + AWS Lambda + DynamoDB + S3 | Live cloud deployment for production campus usage. |

---

## 🚀 Quick Start (Local Development Mode)

### 1. Install Dependencies
```bash
cd coordinator-portal
npm install
```

### 2. Start the Portal & Local Server
```bash
npm start
```

### 3. Open in Browser
Visit **`http://localhost:3001`** in your browser.

---

## 🔍 Core Features

* **Real-Time Queue**: Filter submissions by `Pending Verification`, `Verified`, `Changes Requested`, and `Rejected`.
* **Tamper-Evident Audit Inspector**: Inspect high-res photo proof, cryptographic **SHA-256 Checksums**, and **S3 Storage Keys** to provide tamper-evident integrity verification.
* **Metric Verifier & Adjusters**: Review and validate student metric outputs (*Trees planted, Waste kg recycled, Energy kWh saved, Volunteer hours*).
* **Two-Way Communication**:
  * **Approve & Certify**: Unlocks official UN 5 Pillars scores on the student's mobile app.
  * **Request Changes**: Sends actionable feedback notes to the student's app with one click.
  * **Reject**: Rejects fraudulent or duplicate submissions.
* **REST API Endpoints**: Synchronizes with the iOS client (`POST /contributions`, `GET /contributions`, `POST /contributions/:id/verify`, `GET /student/impact`).
