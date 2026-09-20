//
//  CryptoUtils.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import Foundation
import CryptoKit

enum CryptoUtils {
    /// Calculates SHA-256 hash string for raw Data
    static func sha256(for data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Generates a unique S3 key for evidence uploads
    static func generateS3Key(organisationId: String, studentId: String, filename: String) -> String {
        let dateString = ISO8601DateFormatter().string(from: Date())
        let cleanFilename = filename.replacingOccurrences(of: " ", with: "_")
        return "evidence/\(organisationId)/\(studentId)/\(dateString)_\(cleanFilename)"
    }
}
