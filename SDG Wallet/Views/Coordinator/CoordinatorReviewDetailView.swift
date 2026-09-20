//
//  CoordinatorReviewDetailView.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI
import SwiftData

struct CoordinatorReviewDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var contribution: Contribution
    
    @State private var coordinatorNote: String = ""
    @State private var editedTrees: Int = 0
    @State private var editedWaste: Double = 0.0
    @State private var editedEnergy: Double = 0.0
    @State private var editedWater: Double = 0.0
    @State private var editedHours: Double = 0.0
    @State private var editedPeople: Int = 0
    
    @State private var showSuccessAlert: Bool = false
    @State private var successActionTitle: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Status Badge
                    HStack {
                        Label(contribution.status.title, systemImage: contribution.status.iconName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(contribution.status.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(contribution.status.color.opacity(0.12))
                            .clipShape(Capsule())
                        Spacer()
                        Text(contribution.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // MARK: - Contribution Details
                    VStack(alignment: .leading, spacing: 8) {
                        Text(contribution.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if !contribution.activityDescription.isEmpty {
                            Text(contribution.activityDescription)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        
                        if let loc = contribution.location, !loc.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.green)
                                Text(loc)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 2)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    
                    // MARK: - Photo Proof Evidence
                    if let imagesData = contribution.imagesData, !imagesData.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Submitted Photo Evidence 📷")
                                .font(.headline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(0..<imagesData.count, id: \.self) { idx in
                                        if let uiImg = UIImage(data: imagesData[idx]) {
                                            Image(uiImage: uiImg)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 200, height: 160)
                                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                        }
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(16)
                    }
                    
                    // MARK: - Evidence Cryptographic Audit
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.blue)
                            Text("Evidence Integrity Audit (S3 & SHA-256)")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("S3 Object Key:")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.secondary)
                            Text(contribution.primaryS3Key ?? "evidence/local/\(contribution.id.uuidString).jpg")
                                .font(.system(size: 10, design: .monospaced))
                                .lineLimit(1)
                            
                            Text("SHA-256 Checksum:")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.secondary)
                                .padding(.top, 2)
                            Text(contribution.fileHashSha256 ?? "Checksum computed upon upload")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.blue)
                                .lineLimit(1)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.06))
                        .cornerRadius(10)
                    }
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    
                    // MARK: - Impact Metrics Verification & Adjustment
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.purple)
                            Text("Verify / Adjust Impact Metrics")
                                .font(.headline)
                        }
                        
                        VStack(spacing: 12) {
                            metricStepper(title: "Trees Planted (trees)", icon: "leaf.fill", color: .green, value: $editedTrees)
                            metricDoubleStepper(title: "Waste Recycled (kg)", icon: "arrow.3.circlepath", color: .blue, value: $editedWaste)
                            metricDoubleStepper(title: "Energy Saved (kWh)", icon: "bolt.fill", color: .orange, value: $editedEnergy)
                            metricDoubleStepper(title: "Water Saved (Liters)", icon: "drop.fill", color: .teal, value: $editedWater)
                            metricDoubleStepper(title: "Volunteer Hours (hrs)", icon: "clock.fill", color: .purple, value: $editedHours)
                            metricStepper(title: "People Reached", icon: "person.2.fill", color: .indigo, value: $editedPeople)
                        }
                    }
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    
                    // MARK: - Reviewer Feedback Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Coordinator Feedback Note")
                            .font(.headline)
                        
                        TextField("Add official verification feedback or notes...", text: $coordinatorNote, axis: .vertical)
                            .lineLimit(3...5)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color(uiColor: .tertiarySystemGroupedBackground))
                            .cornerRadius(10)
                    }
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    
                    // MARK: - Action Buttons
                    VStack(spacing: 10) {
                        Button {
                            applyDecision(status: .approved, title: "Verified & Approved")
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                Text("Approve & Verify Impact")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        
                        HStack(spacing: 10) {
                            Button {
                                applyDecision(status: .changesRequested, title: "Requested Changes")
                            } label: {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text("Request Changes")
                                }
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.orange.opacity(0.15))
                                .foregroundColor(.orange)
                                .cornerRadius(12)
                            }
                            
                            Button(role: .destructive) {
                                applyDecision(status: .rejected, title: "Rejected")
                            } label: {
                                HStack {
                                    Image(systemName: "xmark.octagon.fill")
                                    Text("Reject")
                                }
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.red.opacity(0.15))
                                .foregroundColor(.red)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Coordinator Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                self.coordinatorNote = contribution.reviewerNotes ?? ""
                self.editedTrees = contribution.treesPlanted
                self.editedWaste = contribution.wasteRecycledKg
                self.editedEnergy = contribution.energySavedKWh
                self.editedWater = contribution.waterSavedLiters
                self.editedHours = contribution.volunteerHours
                self.editedPeople = contribution.peopleReached
            }
            .alert("Decision Recorded", isPresented: $showSuccessAlert) {
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Contribution has been marked as \(successActionTitle).")
            }
        }
    }
    
    private func applyDecision(status: VerificationStatus, title: String) {
        contribution.status = status
        contribution.reviewerNotes = coordinatorNote.isEmpty ? nil : coordinatorNote
        contribution.verifiedBy = "Campus Sustainability Coordinator"
        contribution.verifiedDate = Date()
        
        // Save verified metrics
        contribution.treesPlanted = editedTrees
        contribution.wasteRecycledKg = editedWaste
        contribution.energySavedKWh = editedEnergy
        contribution.waterSavedLiters = editedWater
        contribution.volunteerHours = editedHours
        contribution.peopleReached = editedPeople
        
        self.successActionTitle = title
        self.showSuccessAlert = true
    }
    
    private func metricStepper(title: String, icon: String, color: Color, value: Binding<Int>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.subheadline)
            Spacer()
            Stepper("\(value.wrappedValue)", value: value, in: 0...100000)
                .font(.subheadline.weight(.semibold))
        }
    }
    
    private func metricDoubleStepper(title: String, icon: String, color: Color, value: Binding<Double>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.subheadline)
            Spacer()
            HStack(spacing: 8) {
                Text("\(Int(value.wrappedValue))")
                    .font(.subheadline.weight(.semibold))
                Stepper("", value: value, in: 0...100000, step: 1.0)
                    .labelsHidden()
            }
        }
    }
}
