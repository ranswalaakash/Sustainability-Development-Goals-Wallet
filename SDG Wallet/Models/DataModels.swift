//
//  DataModels.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - User Roles & User Entity
enum UserRole: String, Codable {
    case student = "STUDENT"
    case coordinator = "COORDINATOR"
}

struct User: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let role: UserRole
    let organisationId: String
    let departmentId: String
}

// MARK: - Verification Status
enum VerificationStatus: String, Codable, CaseIterable {
    case pending = "PENDING"
    case approved = "VERIFIED"
    case changesRequested = "CHANGES_REQUESTED"
    case rejected = "REJECTED"
    
    var title: String {
        switch self {
        case .pending: return "Awaiting Coordinator Verification"
        case .approved: return "Verified by Campus Sustainability Coordinator"
        case .changesRequested: return "Changes Requested"
        case .rejected: return "Submission Rejected"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .pending: return "Awaiting Verification"
        case .approved: return "Verified"
        case .changesRequested: return "Changes Requested"
        case .rejected: return "Rejected"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .approved: return .green
        case .changesRequested: return .orange
        case .rejected: return .red
        }
    }
    
    var iconName: String {
        switch self {
        case .pending: return "clock.fill"
        case .approved: return "checkmark.seal.fill"
        case .changesRequested: return "exclamationmark.triangle.fill"
        case .rejected: return "xmark.octagon.fill"
        }
    }
}

// MARK: - Evidence Metadata (S3 + SHA-256 Hash)
struct EvidenceMetadata: Codable, Hashable, Identifiable {
    var id: String { evidenceId }
    let evidenceId: String
    let s3ObjectKey: String
    let fileHash: String // Cryptographic SHA-256 hash
    let uploadedAt: Date
    let latitude: Double?
    let longitude: Double?
}

// MARK: - SDG Model
struct SDG: Identifiable, Hashable, Codable {
    var id: Int { number }
    
    let number: Int
    let title: String
    let tagline: String
    let description: String
    let colorHex: String
    let imageName: String
    let symbolName: String
    let sectionIDs: [String]
}

struct SDGSection: Identifiable, Hashable, Codable {
    var id: String { title }
    let title: String
    let summary: String
    let keyPoints: [String]
}

// MARK: - SwiftData Contribution Model (DynamoDB Alignment)
@Model
final class Contribution {
    @Attribute(.unique) var id: UUID = UUID()
    var studentId: String = ""
    var studentName: String = ""
    var organisationId: String = ""
    var departmentId: String = ""
    
    var title: String = ""
    var activityDescription: String = ""
    
    @Attribute(.externalStorage) var imagesData: [Data]?
    
    var date: Date = Date.now
    var selectedSDGs: [String] = []
    var sdgIds: [Int] = []
    
    var audioPath: String?
    var location: String?
    var latitude: Double? = nil
    var longitude: Double? = nil
    var taggedPeople: [String] = []
    
    // Status & Coordinator Feedback
    var statusRaw: String = VerificationStatus.pending.rawValue
    var treesPlanted: Int = 0
    var wasteRecycledKg: Double = 0.0
    var energySavedKWh: Double = 0.0
    var waterSavedLiters: Double = 0.0
    var peopleReached: Int = 0
    var volunteerHours: Double = 0.0
    var reviewerNotes: String?
    var verifiedBy: String?
    var verifiedDate: Date?
    
    // Evidence SHA-256 Hashes
    var evidenceHashesJson: String = "[]"
    var primaryS3Key: String?
    var fileHashSha256: String?
    
    var status: VerificationStatus {
        get { VerificationStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }
    
    init(
        id: UUID = UUID(),
        studentId: String = "",
        studentName: String = "",
        organisationId: String = "",
        departmentId: String = "",
        title: String = "",
        activityDescription: String = "",
        imagesData: [Data]? = nil,
        date: Date = .now,
        selectedSDGs: [String] = [],
        sdgIds: [Int] = [],
        audioPath: String? = nil,
        location: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        taggedPeople: [String] = [],
        status: VerificationStatus = .pending,
        treesPlanted: Int = 0,
        wasteRecycledKg: Double = 0,
        energySavedKWh: Double = 0,
        waterSavedLiters: Double = 0,
        peopleReached: Int = 0,
        volunteerHours: Double = 0,
        reviewerNotes: String? = nil,
        verifiedBy: String? = nil,
        verifiedDate: Date? = nil,
        primaryS3Key: String? = nil,
        fileHashSha256: String? = nil
    ) {
        self.id = id
        self.studentId = studentId
        self.studentName = studentName
        self.organisationId = organisationId
        self.departmentId = departmentId
        self.title = title
        self.activityDescription = activityDescription
        self.imagesData = imagesData
        self.date = date
        self.selectedSDGs = selectedSDGs
        self.sdgIds = sdgIds.isEmpty
            ? selectedSDGs.compactMap { sdgString in
                let digits = sdgString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                return Int(digits)
            }
            : sdgIds
        self.audioPath = audioPath
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.taggedPeople = taggedPeople
        self.statusRaw = status.rawValue
        self.treesPlanted = treesPlanted
        self.wasteRecycledKg = wasteRecycledKg
        self.energySavedKWh = energySavedKWh
        self.waterSavedLiters = waterSavedLiters
        self.peopleReached = peopleReached
        self.volunteerHours = volunteerHours
        self.reviewerNotes = reviewerNotes
        self.verifiedBy = verifiedBy
        self.verifiedDate = verifiedDate
        self.primaryS3Key = primaryS3Key
        self.fileHashSha256 = fileHashSha256
    }
}

extension Contribution {
    var sdgNumbers: [Int] {
        if !sdgIds.isEmpty {
            return sdgIds
        }
        
        return selectedSDGs.compactMap { sdgString in
            let digits = sdgString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return Int(digits)
        }
    }
    
    var hasExtractedMetrics: Bool {
        treesPlanted > 0 || wasteRecycledKg > 0 || energySavedKWh > 0 || waterSavedLiters > 0 || peopleReached > 0 || volunteerHours > 0
    }
    
    var primaryMetricSummary: String {
        var parts: [String] = []
        if treesPlanted > 0 { parts.append("🌳 \(treesPlanted) trees planted") }
        if wasteRecycledKg > 0 { parts.append("♻️ \(Int(wasteRecycledKg)) kg waste recycled") }
        if energySavedKWh > 0 { parts.append("⚡️ \(Int(energySavedKWh)) kWh energy saved") }
        if waterSavedLiters > 0 { parts.append("💧 \(Int(waterSavedLiters)) L water saved") }
        if peopleReached > 0 { parts.append("👥 \(peopleReached) people reached") }
        if volunteerHours > 0 { parts.append("⏱️ \(Int(volunteerHours)) volunteer hrs") }
        return parts.joined(separator: " • ")
    }
}

// MARK: - UN Five Pillars Model
enum FivePType: String, CaseIterable, Identifiable, Codable {
    case people, planet, prosperity, peace, partnership
    var id: String { rawValue }
}

struct FivePInfo: Identifiable, Codable {
    var id: FivePType { type }
    
    let type: FivePType
    let title: String
    let shortTagline: String
    let detailedDescription: String
    let sdgNumbers: [Int]
    let colorHex: String
    let symbolName: String
}

struct ImpactSnapshot: Identifiable {
    var id: FivePType { type }
    
    let type: FivePType
    let score: Double
    let activityCount: Int
    let coveredSDGs: [Int]
    let info: FivePInfo
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64
        (r, g, b) = (
            (int >> 16) & 0xFF,
            (int >> 8) & 0xFF,
            int & 0xFF
        )

        self.init(
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0
        )
    }
}
