//
//  ImpactView.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI
import SwiftData

struct ImpactView: View {
    @Environment(\.modelContext) private var context
    @Query private var contributions: [Contribution]
    @StateObject private var vm = ImpactViewModel()

    @State private var showNameAlert = false
    @State private var userName = ""
    @State private var showSharePreview = false
    @State private var selectedSDGNum: Int?
    
    private let orbitRadius: CGFloat = 135
    private let pCircleSize: CGFloat = 84
    private let centralHubSize: CGFloat = 150

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - UN 5 Pillars Section
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("UN Five Pillars")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Scores & metrics are calculated exclusively from coordinator-verified contributions.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 20)
                        
                        mainImpactCard
                    }
                    .padding(.top, 8)
                    
                    // MARK: - Verified Aggregated Metrics
                    if vm.totalVerifiedActivities > 0 {
                        verifiedMetricsSection
                    }
                    
                    // MARK: - SDGs Grid
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sustainable Development Goals")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Tap a goal to view your verified contributions.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 20)
                        
                        sdgGridCard
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Impact")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNameAlert = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .fontWeight(.semibold)
                    }
                }
            }
            .alert("Share Your Impact", isPresented: $showNameAlert) {
                TextField("Your Name", text: $userName)
                    .textInputAutocapitalization(.words)
                Button("Cancel", role: .cancel) { }
                Button("Done") {
                    if !userName.isEmpty {
                        showSharePreview = true
                    }
                }
            } message: {
                Text("Enter your name to personalize your verified impact summary card.")
            }
            .sheet(isPresented: $showSharePreview) {
                ImpactSharePreviewSheet(
                    snapshots: vm.snapshots,
                    userName: userName.isEmpty ? "Student" : userName,
                    totalActivities: vm.totalVerifiedActivities
                )
            }
            .sheet(item: Binding(
                get: { selectedSDGNum.map { SDGItem(id: $0) } },
                set: { selectedSDGNum = $0?.id }
            )) { item in
                SDGDetailSheet(
                    sdg: item.id,
                    count: vm.sdgCounts[item.id] ?? 0,
                    totalHits: vm.totalSDGHits
                )
            }
            .onAppear {
                vm.calculateImpact(from: contributions)
            }
            .onChange(of: contributions.map { "\($0.id)-\($0.statusRaw)" }) { _, _ in
                vm.calculateImpact(from: contributions)
            }
        }
    }
    
    struct SDGItem: Identifiable {
        let id: Int
    }
    
    // MARK: - Main Impact Card (Orbital Diagram)
    private var mainImpactCard: some View {
        VStack(spacing: 24) {
            if vm.totalVerifiedActivities == 0 {
                VStack(spacing: 14) {
                    Image(systemName: "clock.badge.checkmark.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.orange)
                    
                    Text("Awaiting Coordinator Verification")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    Text("Log contributions and get them verified by your campus coordinator to unlock your 5 Pillars Impact.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 30)
            } else {
                OrbitalDiagramView(
                    snapshots: vm.snapshots,
                    orbitRadius: orbitRadius,
                    pCircleSize: pCircleSize,
                    centralHubSize: centralHubSize,
                    isInteractive: true
                ) {
                    VStack(spacing: 2) {
                        Text("Verified\nImpact")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 16)
                
                Divider()
                
                VStack(spacing: 12) {
                    HStack(spacing: 0) {
                        StatView(
                            value: "\(vm.totalVerifiedActivities)",
                            label: vm.totalVerifiedActivities == 1 ? "Verified Initiative" : "Verified Initiatives"
                        )
                        Divider().frame(height: 32)
                        StatView(
                            value: "\(vm.totalSDGHits)",
                            label: vm.totalSDGHits == 1 ? "SDG Contribution" : "SDG Contributions"
                        )
                    }
                    
                    Divider()
                    
                    HStack(spacing: 0) {
                        StatView(
                            value: "\(vm.totalSDGsCovered)/17",
                            label: "SDGs Covered"
                        )
                        Divider().frame(height: 32)
                        StatView(
                            value: "\(vm.snapshots.filter { $0.score > 0 }.count)/5",
                            label: "Pillars Active"
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Verified Metrics Section
    private var verifiedMetricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Verified Quantitative Impact")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal, 20)
            
            VStack(spacing: 10) {
                if vm.verifiedTreesPlanted > 0 {
                    verifiedMetricRow(icon: "leaf.fill", title: "Trees Planted", value: "\(vm.verifiedTreesPlanted) trees", color: .green)
                }
                if vm.verifiedWasteRecycledKg > 0 {
                    verifiedMetricRow(icon: "arrow.3.circlepath", title: "Waste Recycled", value: "\(Int(vm.verifiedWasteRecycledKg)) kg", color: .blue)
                }
                if vm.verifiedEnergySavedKWh > 0 {
                    verifiedMetricRow(icon: "bolt.fill", title: "Energy Saved", value: "\(Int(vm.verifiedEnergySavedKWh)) kWh", color: .orange)
                }
                if vm.verifiedWaterSavedLiters > 0 {
                    verifiedMetricRow(icon: "drop.fill", title: "Water Saved", value: "\(Int(vm.verifiedWaterSavedLiters)) L", color: .teal)
                }
                if vm.verifiedPeopleReached > 0 {
                    verifiedMetricRow(icon: "person.2.fill", title: "People Reached", value: "\(vm.verifiedPeopleReached) people", color: .indigo)
                }
                if vm.verifiedVolunteerHours > 0 {
                    verifiedMetricRow(icon: "clock.fill", title: "Volunteer Hours", value: "\(Int(vm.verifiedVolunteerHours)) hrs", color: .purple)
                }
            }
            .padding(16)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(20)
            .padding(.horizontal, 16)
        }
    }
    
    private func verifiedMetricRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.headline)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundColor(color)
        }
    }
    
    // MARK: - SDG Grid
    private var sdgGridCard: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
            ForEach(1...17, id: \.self) { sdg in
                Button {
                    selectedSDGNum = sdg
                } label: {
                    Image("SDG_\(sdg)")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 65)
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                        .opacity((vm.sdgCounts[sdg] ?? 0) > 0 ? 1.0 : 0.25)
                        .saturation((vm.sdgCounts[sdg] ?? 0) > 0 ? 1.0 : 0.0)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
}

// MARK: - Supporting Subviews
struct StatView: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(.primary)

            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SDGDetailSheet: View {
    let sdg: Int
    let count: Int
    let totalHits: Int

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
            
            Image("SDG_\(sdg)")
                .resizable()
                .scaledToFit()
                .frame(height: 110)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            
            if count > 0 {
                VStack(spacing: 6) {
                    Text("Verified Contributions: **\(count)**")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    let percentage = totalHits > 0 ? Int((Double(count) / Double(totalHits)) * 100) : 0
                    Text("Makes up \(percentage)% of your total verified impact.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("No verified contributions logged for Goal \(sdg) yet.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
        .presentationDetents([.height(280)])
    }
}

struct ImpactSharePreviewSheet: View {
    let snapshots: [ImpactSnapshot]
    let userName: String
    let totalActivities: Int
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ShareableImpactCard(
                    snapshots: snapshots,
                    userName: userName,
                    totalActivities: totalActivities
                )
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                .scaleEffect(0.9)
                
                Spacer()
            }
            .navigationTitle("Share Impact Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
