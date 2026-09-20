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
    @State private var isSharing = false
    @State private var showShareSuccessAlert = false
    @State private var showResubmitSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                
                // MARK: - 1. Title Header
                Text(contribution.title.isEmpty ? "Untitled Action" : contribution.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top, 4)
                
                // MARK: - 2. Main Photo Evidence
                if let imagesData = contribution.imagesData, let firstData = imagesData.first, let uiImg = UIImage(data: firstData) {
                    Image(uiImage: uiImg)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                }
                
                // MARK: - 3. Narrative Description
                if !contribution.activityDescription.isEmpty {
                    Text(contribution.activityDescription)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.top, 2)
                }
                
                // MARK: - 4. Portal Status Row
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(statusColor.opacity(0.12))
                            .frame(width: 44, height: 44)
                        Image(systemName: statusIconName)
                            .font(.title3)
                            .foregroundColor(statusColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PORTAL STATUS")
                            .font(.caption2.weight(.bold))
                            .tracking(1.0)
                            .foregroundStyle(.secondary)
                        
                        Text(statusTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 6)
                
                // Coordinator Feedback Note (if present)
                if let notes = contribution.reviewerNotes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: contribution.status == .approved ? "person.badge.shield.checkmark.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(statusColor)
                            Text(contribution.status == .approved ? "Coordinator Verification Note" : "Coordinator Feedback")
                                .font(.caption.weight(.bold))
                                .foregroundColor(statusColor)
                        }
                        Text(notes)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(statusColor.opacity(0.08))
                    .cornerRadius(14)
                }
                
                // MARK: - 5. Action Button (Share to Department Portal)
                Button {
                    shareToPortal()
                } label: {
                    HStack(spacing: 8) {
                        if isSharing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "paperplane.fill")
                            Text(actionButtonTitle)
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(actionButtonColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(color: actionButtonColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(isSharing)
                
                Divider()
                    .padding(.vertical, 4)
                
                // MARK: - 6. SDG Covered Section
                VStack(alignment: .leading, spacing: 14) {
                    Text("SDG Covered")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    if contribution.sdgNumbers.isEmpty {
                        Text("No specific SDGs linked.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        HStack(spacing: 12) {
                            ForEach(contribution.sdgNumbers, id: \.self) { num in
                                Image("SDG_\(num)")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 86, height: 86)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 40)
        }
        .background(Color(uiColor: .systemBackground))
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
        .alert("Shared to Portal", isPresented: $showShareSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("Your contribution has been shared to the Campus Coordinator Portal for verification.")
        }
        .sheet(isPresented: $showResubmitSheet) {
            ResubmitContributionSheet(contribution: contribution)
        }
        .refreshable {
            await syncStatus()
        }
        .onAppear {
            Task {
                await syncStatus()
            }
        }
    }
    
    // MARK: - Status Properties
    private var statusTitle: String {
        switch contribution.status {
        case .pending:
            return "Saved on this device"
        case .approved:
            return "Verified by Coordinator"
        case .changesRequested:
            return "Changes requested by Coordinator"
        case .rejected:
            return "Rejected by Coordinator"
        }
    }
    
    private var statusIconName: String {
        switch contribution.status {
        case .pending:
            return "checkmark.seal"
        case .approved:
            return "checkmark.seal.fill"
        case .changesRequested:
            return "exclamationmark.triangle.fill"
        case .rejected:
            return "xmark.octagon.fill"
        }
    }
    
    private var statusColor: Color {
        switch contribution.status {
        case .pending:
            return .secondary
        case .approved:
            return .green
        case .changesRequested:
            return .orange
        case .rejected:
            return .red
        }
    }
    
    private var actionButtonTitle: String {
        switch contribution.status {
        case .pending:
            return "Share to Department Portal"
        case .approved:
            return "Verified on Portal"
        case .changesRequested:
            return "Edit & Resubmit to Portal"
        case .rejected:
            return "Resubmit to Portal"
        }
    }
    
    private var actionButtonColor: Color {
        switch contribution.status {
        case .pending:
            return Color.green
        case .approved:
            return Color.green
        case .changesRequested:
            return Color.orange
        case .rejected:
            return Color.red
        }
    }
    
    // MARK: - Actions
    private func shareToPortal() {
        if contribution.status == .changesRequested {
            showResubmitSheet = true
            return
        }
        
        isSharing = true
        Task {
            _ = try? await APIService.shared.submitContribution(contribution)
            await MainActor.run {
                isSharing = false
                showShareSuccessAlert = true
            }
        }
    }
    
    private func syncStatus() async {
        if let result = try? await APIService.shared.fetchContributionStatus(id: contribution.id) {
            await MainActor.run {
                contribution.status = result.status
                if let note = result.note {
                    contribution.reviewerNotes = note
                }
                if let reviewer = result.reviewer {
                    contribution.verifiedBy = reviewer
                }
            }
        }
    }
}

// MARK: - Resubmit Updates Sheet
struct ResubmitContributionSheet: View {
    @Bindable var contribution: Contribution
    @Environment(\.dismiss) private var dismiss
    
    @State private var updatedTitle: String = ""
    @State private var updatedDescription: String = ""
    @State private var isSubmitting: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    
                    if let note = contribution.reviewerNotes {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Coordinator Feedback:")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.orange)
                            }
                            Text(note)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.12))
                        .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Title")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        TextField("Title", text: $updatedTitle)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Updated Description")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        TextField("Provide updated details...", text: $updatedDescription, axis: .vertical)
                            .lineLimit(4...8)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(10)
                    }
                    
                    Button {
                        resubmit()
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "paperplane.fill")
                                Text("Resubmit to Department Portal")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                    .disabled(updatedTitle.isEmpty || isSubmitting)
                    .padding(.top, 10)
                }
                .padding(16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Update Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                self.updatedTitle = contribution.title
                self.updatedDescription = contribution.activityDescription
            }
        }
    }
    
    private func resubmit() {
        isSubmitting = true
        contribution.title = updatedTitle
        contribution.activityDescription = updatedDescription
        contribution.status = .pending
        contribution.reviewerNotes = nil
        contribution.date = Date()
        
        Task {
            _ = try? await APIService.shared.submitContribution(contribution)
            await MainActor.run {
                isSubmitting = false
                dismiss()
            }
        }
    }
}
