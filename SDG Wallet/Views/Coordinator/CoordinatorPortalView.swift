//
//  CoordinatorPortalView.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI
import SwiftData

struct CoordinatorPortalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Contribution.date, order: .reverse) private var allContributions: [Contribution]
    
    @State private var selectedFilter: ReviewFilter = .pending
    @State private var selectedContribution: Contribution?
    
    enum ReviewFilter: String, CaseIterable, Identifiable {
        case pending = "Pending"
        case verified = "Verified"
        case changes = "Changes"
        case rejected = "Rejected"
        case all = "All"
        
        var id: String { rawValue }
    }
    
    private var filteredContributions: [Contribution] {
        switch selectedFilter {
        case .pending:
            return allContributions.filter { $0.status == .pending }
        case .verified:
            return allContributions.filter { $0.status == .approved }
        case .changes:
            return allContributions.filter { $0.status == .changesRequested }
        case .rejected:
            return allContributions.filter { $0.status == .rejected }
        case .all:
            return allContributions
        }
    }
    
    private var pendingCount: Int {
        allContributions.filter { $0.status == .pending }.count
    }
    
    private var verifiedCount: Int {
        allContributions.filter { $0.status == .approved }.count
    }
    
    private var totalVerifiedTrees: Int {
        allContributions.filter { $0.status == .approved }.reduce(0) { $0 + $1.treesPlanted }
    }
    
    private var totalVerifiedWasteKg: Double {
        allContributions.filter { $0.status == .approved }.reduce(0) { $0 + $1.wasteRecycledKg }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // MARK: - Coordinator Summary Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("CAMPUS SUSTAINABILITY")
                                    .font(.caption2.weight(.bold))
                                    .tracking(1.2)
                                    .foregroundColor(.purple)
                                
                                Text("Coordinator Portal")
                                    .font(.title2.weight(.bold))
                            }
                            Spacer()
                            Image(systemName: "person.badge.shield.checkmark.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.purple)
                        }
                        
                        Text("Audit evidence photos, verify impact metrics, and approve contributions to the institutional record.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Divider()
                        
                        HStack(spacing: 12) {
                            portalStatBadge(title: "Awaiting Review", value: "\(pendingCount)", color: .orange, icon: "clock.fill")
                            portalStatBadge(title: "Verified Impact", value: "\(verifiedCount)", color: .green, icon: "checkmark.seal.fill")
                            portalStatBadge(title: "Trees Verified", value: "\(totalVerifiedTrees)", color: .teal, icon: "leaf.fill")
                        }
                    }
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 3)
                    
                    // MARK: - Filter Segmented Control
                    Picker("Filter Submissions", selection: $selectedFilter) {
                        ForEach(ReviewFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // MARK: - Queue Header
                    HStack {
                        Text("\(selectedFilter.rawValue) Queue (\(filteredContributions.count))")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    // MARK: - Submissions List
                    if filteredContributions.isEmpty {
                        emptyQueueView
                    } else {
                        VStack(spacing: 12) {
                            ForEach(filteredContributions) { entry in
                                coordinatorCard(for: entry)
                                    .onTapGesture {
                                        selectedContribution = entry
                                    }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Coordinator")
            .sheet(item: $selectedContribution) { entry in
                CoordinatorReviewDetailView(contribution: entry)
            }
        }
    }
    
    private func portalStatBadge(title: String, value: String, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.title3.weight(.bold))
                .fontDesign(.rounded)
            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func coordinatorCard(for entry: Contribution) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                if let images = entry.imagesData, let firstData = images.first, let uiImg = UIImage(data: firstData) {
                    Image(uiImage: uiImg)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 54, height: 54)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                            .frame(width: 54, height: 54)
                        Image(systemName: "photo.badge.exclamationmark")
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(entry.title.isEmpty ? "Untitled Action" : entry.title)
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        Spacer()
                        Text(entry.status.shortTitle)
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(entry.status.color.opacity(0.15))
                            .foregroundColor(entry.status.color)
                            .clipShape(Capsule())
                    }
                    
                    if !entry.activityDescription.isEmpty {
                        Text(entry.activityDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: 6) {
                        Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                        
                        if let loc = entry.location, !loc.isEmpty {
                            Text("• \(loc)")
                                .font(.system(size: 10))
                                .foregroundStyle(.tertiary)
                                .lineLimit(1)
                        }
                    }
                }
            }
            
            Divider()
            
            HStack {
                if entry.hasExtractedMetrics {
                    Text(entry.primaryMetricSummary)
                        .font(.caption2.weight(.bold))
                        .foregroundColor(entry.status == .approved ? .green : .orange)
                        .lineLimit(1)
                } else {
                    Text("No metrics logged")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Review & Audit")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.purple)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.purple)
                }
            }
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
    
    private var emptyQueueView: some View {
        VStack(spacing: 12) {
            Image(systemName: selectedFilter == .pending ? "checkmark.circle.badge.questionmark" : "tray")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("No \(selectedFilter.rawValue) Submissions")
                .font(.headline)
            
            Text("Submissions logged by students will appear here for verification.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}
