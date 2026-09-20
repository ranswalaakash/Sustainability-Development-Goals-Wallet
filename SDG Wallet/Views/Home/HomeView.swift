//
//  HomeView.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Contribution.date, order: .reverse) private var contributions: [Contribution]
    
    @Binding var selectedTab: Int
    
    private var pendingContributions: [Contribution] {
        contributions.filter { $0.status == .pending }
    }
    
    private var verifiedContributions: [Contribution] {
        contributions.filter { $0.status == .approved }
    }
    
    private var verifiedTrees: Int {
        verifiedContributions.reduce(0) { $0 + $1.treesPlanted }
    }
    
    private var verifiedWaste: Double {
        verifiedContributions.reduce(0) { $0 + $1.wasteRecycledKg }
    }
    
    private var verifiedEnergy: Double {
        verifiedContributions.reduce(0) { $0 + $1.energySavedKWh }
    }
    
    private var verifiedVolunteerHrs: Double {
        verifiedContributions.reduce(0) { $0 + $1.volunteerHours }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - 1. Top: Verified Impact Metrics Summary Card
                    verifiedImpactCard
                    
                    // MARK: - 2. Middle: Pending Verification Queue Section
                    if !pendingContributions.isEmpty {
                        pendingSection
                    }
                    
                    // MARK: - 3. Log Action Callout
                    logActionHeroCard
                    
                    // MARK: - 4. Bottom: Recent Activity Feed
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Submissions")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        if contributions.isEmpty {
                            emptyFeedCard
                        } else {
                            ForEach(contributions) { entry in
                                NavigationLink(destination: ActivityDetailView(contribution: entry)) {
                                    ContributionRow(entry: entry)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("SDG Wallet")
        }
    }
    
    // MARK: - Top: Verified Impact Card
    private var verifiedImpactCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("OFFICIAL CAMPUS IMPACT")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .tracking(1.2)
                        .foregroundStyle(.green)
                    
                    Text("Verified Student Impact")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.green)
            }
            
            Text("Only metrics verified by Campus Sustainability Coordinators count toward official institutional impact.")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Divider()
            
            HStack(spacing: 10) {
                MetricCard(
                    title: "Trees Planted",
                    value: "\(verifiedTrees)",
                    unit: "trees",
                    iconName: "leaf.fill",
                    color: .green
                )
                MetricCard(
                    title: "Waste Recycled",
                    value: "\(Int(verifiedWaste))",
                    unit: "kg",
                    iconName: "arrow.3.circlepath",
                    color: .blue
                )
                MetricCard(
                    title: "Energy Saved",
                    value: "\(Int(verifiedEnergy))",
                    unit: "kWh",
                    iconName: "bolt.fill",
                    color: .orange
                )
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
    
    // MARK: - Middle: Pending Verification Section
    private var pendingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "clock.badge.exclamationmark.fill")
                    .foregroundColor(.orange)
                    .font(.headline)
                Text("Awaiting Coordinator Verification (\(pendingContributions.count))")
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            
            Text("The following submission has been AI-analyzed and sent to campus coordinators for verification:")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ForEach(pendingContributions) { entry in
                NavigationLink(destination: ActivityDetailView(contribution: entry)) {
                    HStack(spacing: 12) {
                        Image(systemName: "hourglass.bottomhalf.filled")
                            .font(.title3)
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            if entry.hasExtractedMetrics {
                                Text("Extracted: \(entry.primaryMetricSummary)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(12)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(Color.orange.opacity(0.08))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.25), lineWidth: 1)
        )
    }
    
    // MARK: - Log Action Hero Card
    private var logActionHeroCard: some View {
        Button {
            selectedTab = 1 // Switch to Contribute Tab
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Log New Contribution")
                        .font(.headline)
                    Text("Submit text, photo evidence & location for AI extraction")
                        .font(.caption)
                        .opacity(0.9)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
            }
            .padding(14)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Empty Feed Card
    private var emptyFeedCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No contributions logged yet")
                .font(.headline)
            Text("Tap 'Log New Contribution' to record and submit a sustainability action.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, 16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

// MARK: - Supporting Subviews
struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let iconName: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(color)
                    .font(.subheadline)
                Spacer()
            }
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .fontDesign(.rounded)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct ContributionRow: View {
    let entry: Contribution
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(entry.status.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: entry.status.iconName)
                    .foregroundColor(entry.status.color)
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.title)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Text(entry.status.shortTitle)
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(entry.status.color.opacity(0.15))
                        .foregroundColor(entry.status.color)
                        .clipShape(Capsule())
                }
                
                if entry.hasExtractedMetrics {
                    Text(entry.primaryMetricSummary)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(entry.status == .approved ? .green : .orange)
                        .lineLimit(1)
                } else {
                    Text(entry.activityDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    if let location = entry.location, !location.isEmpty {
                        Text("• \(location)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(14)
    }
}
