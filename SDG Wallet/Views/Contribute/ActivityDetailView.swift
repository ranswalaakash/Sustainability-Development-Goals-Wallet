//
//  ActivityDetailView.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI
import SwiftData

struct ActivityDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var contribution: Contribution
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - 1. Verification Status Banner
                statusBanner
                
                // MARK: - 2. Verification Timeline Component
                verificationTimelineCard
                
                // MARK: - 3. Activity Overview
                VStack(alignment: .leading, spacing: 12) {
                    Text(contribution.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(contribution.date.formatted(date: .long, time: .shortened))
                            .font(.caption)
                        
                        if let loc = contribution.location, !loc.isEmpty {
                            Text("•")
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption)
                            Text(loc)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                    .foregroundStyle(.secondary)
                    
                    Text(contribution.activityDescription)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .padding(.top, 4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(16)
                
                // MARK: - Photo Evidence
                if let imagesData = contribution.imagesData, !imagesData.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Photo Evidence 📷")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<imagesData.count, id: \.self) { idx in
                                    if let uiImg = UIImage(data: imagesData[idx]) {
                                        Image(uiImage: uiImg)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 140, height: 140)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(16)
                }
                
                // MARK: - Evidence Integrity (SHA-256 Checksum)
                evidenceIntegrityCard
                
                // MARK: - 4. AI-Assisted Analysis & Extractions Card
                aiExtractionSection
                
                // MARK: - 5. Coordinator Notes (if verified/reviewed)
                if let notes = contribution.reviewerNotes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "person.badge.shield.checkmark.fill")
                                .foregroundColor(contribution.status == .approved ? .green : (contribution.status == .changesRequested ? .orange : .red))
                            Text(contribution.status == .approved ? "Coordinator Verification Note" : (contribution.status == .changesRequested ? "Requested Correction" : "Rejection Reason"))
                                .font(.headline)
                        }
                        Text(notes)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(contribution.status.color.opacity(0.1))
                    .cornerRadius(16)
                }
                
                // MARK: - Delete Contribution Button
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Contribution")
                    }
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(14)
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .refreshable {
            if let result = try? await APIService.shared.fetchContributionStatus(id: contribution.id) {
                await MainActor.run {
                    contribution.status = result.status
                    if let note = result.note {
                        contribution.reviewerNotes = note
                    }
                }
            }
        }
        .confirmationDialog(
            "Delete Contribution",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                modelContext.delete(contribution)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to permanently delete this contribution?")
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Contribution Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    // MARK: - Status Banner
    private var statusBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(contribution.status.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: contribution.status.iconName)
                    .font(.title3)
                    .foregroundColor(contribution.status.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(contribution.status.title)
                    .font(.headline)
                    .foregroundColor(contribution.status.color)
                
                if contribution.status == .pending {
                    Text("Submitted to Campus Sustainability Coordinator")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if contribution.status == .approved {
                    Text("Impact verified • Added to official 5 Pillars score")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if contribution.status == .changesRequested {
                    Text("Coordinator requested revision. Please review feedback note.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Submission rejected by Coordinator.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(14)
        .background(contribution.status.color.opacity(0.12))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(contribution.status.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Verification Timeline Card
    private var verificationTimelineCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Verification Timeline")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
            
            HStack(alignment: .top, spacing: 0) {
                TimelineStepView(
                    stepNumber: 1,
                    title: "Submitted",
                    subtitle: contribution.date.formatted(date: .abbreviated, time: .shortened),
                    isCompleted: true,
                    isCurrent: false,
                    isLast: false
                )
                
                TimelineStepView(
                    stepNumber: 2,
                    title: "Evidence",
                    subtitle: "SHA-256 S3",
                    isCompleted: true,
                    isCurrent: false,
                    isLast: false
                )
                
                TimelineStepView(
                    stepNumber: 3,
                    title: "AI Analyzed",
                    subtitle: "\(contribution.sdgNumbers.count) SDGs",
                    isCompleted: true,
                    isCurrent: false,
                    isLast: false
                )
                
                TimelineStepView(
                    stepNumber: 4,
                    title: "Coordinator",
                    subtitle: contribution.status == .pending ? "Awaiting" : "Reviewed",
                    isCompleted: contribution.status != .pending,
                    isCurrent: contribution.status == .pending,
                    isLast: false
                )
                
                TimelineStepView(
                    stepNumber: 5,
                    title: contribution.status == .approved ? "Verified" : (contribution.status == .changesRequested ? "Changes" : (contribution.status == .rejected ? "Rejected" : "Impact")),
                    subtitle: contribution.status == .approved ? "Official" : "Final",
                    isCompleted: contribution.status == .approved,
                    isCurrent: contribution.status == .approved,
                    isLast: true
                )
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Evidence Integrity Card
    private var evidenceIntegrityCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.blue)
                Text("Evidence Integrity (S3 Metadata)")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.blue)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("S3 Object Key:")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(contribution.primaryS3Key ?? "Local Only (Pending Sync)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text("SHA-256 Checksum:")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
                Text(contribution.fileHashSha256 ?? "None (No photo attached)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(contribution.fileHashSha256 != nil ? .blue : .secondary)
                    .lineLimit(1)
            }
            .padding(10)
            .background(Color.blue.opacity(0.06))
            .cornerRadius(10)
            
            Text("Verifies the submitted evidence file has not been altered after recording.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - AI Extractions Section
    private var aiExtractionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("AI-Assisted Analysis — Human Verification Required")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.purple)
                Spacer()
            }
            
            Text("AI can suggest. Humans verify. Only verified contributions count toward official impact.")
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Suggested SDGs:")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                
                ForEach(contribution.sdgNumbers, id: \.self) { num in
                    let sdgObj = sdgs.first(where: { $0.number == num })
                    HStack(spacing: 10) {
                        Image("SDG_\(num)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .cornerRadius(6)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SDG \(num): \(sdgObj?.title ?? "")")
                                .font(.subheadline.weight(.semibold))
                            Text(sdgObj?.tagline ?? "")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: sdgObj?.colorHex ?? "#3F7E44").opacity(0.12))
                    .cornerRadius(10)
                }
            }
            
            if contribution.hasExtractedMetrics {
                Divider()
                Text("Extracted Impact Metrics:")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    if contribution.treesPlanted > 0 {
                        metricRow(icon: "leaf.fill", label: "Trees Planted", value: "\(contribution.treesPlanted) trees", color: .green)
                    }
                    if contribution.wasteRecycledKg > 0 {
                        metricRow(icon: "arrow.3.circlepath", label: "Waste Recycled", value: "\(Int(contribution.wasteRecycledKg)) kg", color: .blue)
                    }
                    if contribution.energySavedKWh > 0 {
                        metricRow(icon: "bolt.fill", label: "Energy Saved", value: "\(Int(contribution.energySavedKWh)) kWh", color: .orange)
                    }
                    if contribution.waterSavedLiters > 0 {
                        metricRow(icon: "drop.fill", label: "Water Saved", value: "\(Int(contribution.waterSavedLiters)) L", color: .teal)
                    }
                    if contribution.peopleReached > 0 {
                        metricRow(icon: "person.2.fill", label: "People Reached", value: "\(contribution.peopleReached) people", color: .indigo)
                    }
                    if contribution.volunteerHours > 0 {
                        metricRow(icon: "clock.fill", label: "Volunteer Hours", value: "\(Int(contribution.volunteerHours)) hrs", color: .purple)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.purple.opacity(0.06))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func metricRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundColor(color)
        }
    }
}

// MARK: - Timeline Step Component
struct TimelineStepView: View {
    let stepNumber: Int
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let isCurrent: Bool
    let isLast: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 0) {
                if stepNumber > 1 {
                    Rectangle()
                        .fill(isCompleted || isCurrent ? Color.green : Color.secondary.opacity(0.2))
                        .frame(height: 2)
                }
                
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.green : (isCurrent ? Color.orange : Color.secondary.opacity(0.2)))
                        .frame(width: 24, height: 24)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text("\(stepNumber)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(isCurrent ? .white : .secondary)
                    }
                }
                
                if !isLast {
                    Rectangle()
                        .fill(isCompleted ? Color.green : Color.secondary.opacity(0.2))
                        .frame(height: 2)
                }
            }
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 10, weight: isCurrent || isCompleted ? .bold : .medium))
                    .foregroundColor(isCompleted ? .green : (isCurrent ? .orange : .secondary))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.system(size: 8))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
