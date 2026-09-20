//
//  APIService.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import Foundation
import Combine

public struct PresignedUploadResponse: Codable, Sendable {
    public let uploadUrl: String
    public let s3ObjectKey: String
    public let bucket: String
    public let expiresInSeconds: Int?
}

public struct ContributionDTO: Codable, Sendable {
    public let id: String
    public let studentId: String
    public let studentName: String
    public let organisationId: String
    public let departmentId: String
    public let title: String
    public let description: String
    public let latitude: Double?
    public let longitude: Double?
    public let locationName: String?
    public let status: String
    public let createdAt: String
    public let verifiedAt: String?
    public let verifiedBy: String?
    public let coordinatorNote: String?
    public let sdgIds: [Int]
    public let metrics: MetricDTO?
}

public struct MetricDTO: Codable, Sendable {
    public let treesPlanted: Int?
    public let wasteRecycledKg: Double?
    public let energySavedKWh: Double?
    public let waterSavedLiters: Double?
    public let peopleReached: Int?
    public let volunteerHours: Double?
}

public struct VerifiedImpactSummaryDTO: Codable, Sendable {
    public let studentId: String
    public let verifiedCount: Int
    public let verifiedSdgs: [Int]
    public let metrics: MetricDTO
    public let pillars: [String: Int]
    public let policyNote: String?
}

actor APIService {
    static let shared = APIService()
    
    // AWS API Gateway Base Endpoint URL (Configurable via environment / UserDefaults)
    // Production AWS API Gateway example: https://xyz123.execute-api.us-east-1.amazonaws.com
    // Fallback: Local dev server http://localhost:3001
    private var customBaseURL: URL?
    
    private var effectiveBaseURL: URL {
        if let custom = customBaseURL {
            return custom
        }
        if let stored = UserDefaults.standard.string(forKey: "AWS_API_GATEWAY_URL"),
           let url = URL(string: stored) {
            return url
        }
        return URL(string: "http://localhost:3001")!
    }
    
    private init() { }
    
    func setBaseURL(_ url: URL?) {
        self.customBaseURL = url
    }
    
    // MARK: - 1. Request S3 Presigned URL for Evidence Upload
    func requestPresignedUrl(
        filename: String,
        contentType: String = "image/jpeg",
        studentId: String = "",
        orgId: String = ""
    ) async throws -> PresignedUploadResponse {
        let endpoint = effectiveBaseURL.appendingPathComponent("contributions/presign")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "filename": filename,
            "contentType": contentType,
            "studentId": studentId,
            "organisationId": orgId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(PresignedUploadResponse.self, from: data)
    }
    
    // MARK: - 2. Direct S3 Upload via Presigned URL
    func uploadToS3(data: Data, presignedUrlString: String, contentType: String = "image/jpeg") async throws {
        guard let url = URL(string: presignedUrlString) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.cannotCreateFile)
        }
    }
    
    // MARK: - 3. Submit Contribution Workflow
    /// Computes SHA-256 checksums, requests S3 presigned URL, uploads photo evidence to S3, and records entry in DynamoDB
    func submitContribution(_ contribution: Contribution) async throws -> (s3Key: String?, hash: String?) {
        var primaryKey = contribution.primaryS3Key
        var hashString = contribution.fileHashSha256
        
        // 1. Calculate SHA-256 for local image evidence
        if let images = contribution.imagesData, let firstImage = images.first {
            hashString = CryptoUtils.sha256(for: firstImage)
            let orgPrefix = contribution.organisationId.isEmpty ? "default_org" : contribution.organisationId
            let studentPrefix = contribution.studentId.isEmpty ? "student" : contribution.studentId
            
            primaryKey = CryptoUtils.generateS3Key(
                organisationId: orgPrefix,
                studentId: studentPrefix,
                filename: "\(contribution.id.uuidString).jpg"
            )
            
            // 2. Attempt direct S3 upload via presigned URL if remote backend is reachable
            do {
                let presigned = try await requestPresignedUrl(
                    filename: "\(contribution.id.uuidString).jpg",
                    contentType: "image/jpeg",
                    studentId: contribution.studentId,
                    orgId: contribution.organisationId
                )
                try await uploadToS3(data: firstImage, presignedUrlString: presigned.uploadUrl)
                primaryKey = presigned.s3ObjectKey
            } catch {
                print("[APIService] Direct S3 upload skipped (offline or unconfigured mode): \(error.localizedDescription)")
            }
        }
        
        contribution.fileHashSha256 = hashString
        contribution.primaryS3Key = primaryKey
        
        // 3. Post metadata to DynamoDB via API Gateway
        let endpoint = effectiveBaseURL.appendingPathComponent("contributions")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [
            "id": contribution.id.uuidString,
            "studentId": contribution.studentId,
            "studentName": contribution.studentName,
            "organisationId": contribution.organisationId,
            "departmentId": contribution.departmentId,
            "title": contribution.title,
            "description": contribution.activityDescription,
            "sdgIds": contribution.sdgIds,
            "metrics": [
                "treesPlanted": contribution.treesPlanted,
                "wasteRecycledKg": contribution.wasteRecycledKg,
                "energySavedKWh": contribution.energySavedKWh,
                "waterSavedLiters": contribution.waterSavedLiters,
                "peopleReached": contribution.peopleReached,
                "volunteerHours": contribution.volunteerHours
            ]
        ]
        
        if let lat = contribution.latitude { body["latitude"] = lat }
        if let lon = contribution.longitude { body["longitude"] = lon }
        if let loc = contribution.location { body["locationName"] = loc }
        if let key = primaryKey { body["s3ObjectKey"] = key }
        if let hash = hashString { body["fileHashSha256"] = hash }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (_, _) = try await URLSession.shared.data(for: request)
        } catch {
            print("[APIService] Remote DynamoDB sync skipped: \(error.localizedDescription)")
        }
        
        return (primaryKey, hashString)
    }
    
    // MARK: - 4. Fetch Verified Impact Summary (Server-Side Verified Only)
    func fetchVerifiedImpact(studentId: String) async throws -> VerifiedImpactSummaryDTO {
        let endpoint = effectiveBaseURL.appendingPathComponent("student/impact")
            .appending(queryItems: [URLQueryItem(name: "studentId", value: studentId)])
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(VerifiedImpactSummaryDTO.self, from: data)
    }
    
    // MARK: - 5. Fetch Single Contribution Status
    func fetchContributionStatus(id: UUID) async throws -> (status: VerificationStatus, note: String?, reviewer: String?)? {
        let endpoint = effectiveBaseURL.appendingPathComponent("contributions/\(id.uuidString)")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            return nil
        }
        
        struct SingleResponse: Codable {
            let contribution: ContributionDTO
        }
        
        let res = try JSONDecoder().decode(SingleResponse.self, from: data)
        let statusString = res.contribution.status.uppercased()
        let parsedStatus: VerificationStatus
        if statusString.contains("VERIF") || statusString.contains("APPROV") {
            parsedStatus = .approved
        } else if statusString.contains("CHANGE") {
            parsedStatus = .changesRequested
        } else if statusString.contains("REJECT") {
            parsedStatus = .rejected
        } else {
            parsedStatus = .pending
        }
        
        return (parsedStatus, res.contribution.coordinatorNote, res.contribution.verifiedBy)
    }
}
