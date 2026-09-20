# 🌿 SDG Wallet — Campus Sustainability Coordinator Web Portal

A dedicated, standalone web portal for **Campus Sustainability Coordinators** to review, audit, verify, and communicate with students on real-world sustainability contributions.

---

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd coordinator-portal
npm install
```

### 2. Start the Portal & API Server
```bash
npm start
```

### 3. Open in Browser
Visit **`http://localhost:3001`** in your browser.

---

## 🔍 Features

* **Real-Time Queue**: Filter submissions by `Pending Verification`, `Verified`, `Changes Requested`, and `Rejected`.
* **Tamper-Proof Audit**: Inspect high-res photo proof, cryptographic **SHA-256 Checksums**, and **S3 Storage Keys**.
* **Metric Verifier & Steppers**: Review and adjust student metrics (*Trees, Waste kg, Energy kWh, Volunteer hours*).
* **Two-Way Communication**:
  * **Approve & Certify**: Unlocks official UN 5 Pillars scores on the student's mobile app.
  * **Request Changes**: Sends actionable feedback notes to the student's app with one click.
  * **Reject**: Rejects fraudulent or duplicate submissions.
* **REST API Endpoints**: Synchronizes seamlessly with the iOS client (`POST /contributions`, `GET /contributions`, `POST /contributions/:id/verify`, `GET /student/impact`).
