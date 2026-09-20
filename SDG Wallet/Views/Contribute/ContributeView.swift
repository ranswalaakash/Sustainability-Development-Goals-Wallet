//
//  ContributeView.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ContributeView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedTab: Int
    
    @State private var title: String = ""
    @State private var activityDescription: String = ""
    @State private var location: String = ""
    
    // Photo selection
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImageData: [Data] = []
    
    // AI Analysis State
    @State private var analysis: ActivityAnalysis?
    @State private var isAnalyzing: Bool = false
    @State private var selectedSDGIds: Set<Int> = []
    
    @State private var createdContribution: Contribution?
    @State private var showDetailSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Log Contribution")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Document your sustainability action for coordinator verification.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 4)
                    
                    // MARK: - Input Section
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Activity Title")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            
                            TextField("e.g. Planted 5 trees during campus drive", text: $title)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                                .cornerRadius(10)
                                .onChange(of: title) { _, _ in runAIAnalysis() }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Description & Details")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            
                            TextField("Describe what was done, quantities, and partners involved...", text: $activityDescription, axis: .vertical)
                                .lineLimit(3...6)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                                .cornerRadius(10)
                                .onChange(of: activityDescription) { _, _ in runAIAnalysis() }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Location Evidence 📍")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.green)
                                TextField("e.g. Student Center Lawn, Main Campus", text: $location)
                                    .textFieldStyle(.plain)
                            }
                            .padding(12)
                            .background(Color(uiColor: .tertiarySystemGroupedBackground))
                            .cornerRadius(10)
                        }
                    }
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    
                    // MARK: - Evidence Upload Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Attach Photo Evidence 📷")
                            .font(.headline)
                        
                        PhotosPicker(
                            selection: $selectedItems,
                            maxSelectionCount: 3,
                            matching: .images
                        ) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text(selectedImageData.isEmpty ? "Select Photos from Library" : "\(selectedImageData.count) Photo(s) Attached")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(.subheadline.weight(.semibold))
                            .padding(14)
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.12))
                            .foregroundColor(.green)
                            .cornerRadius(12)
                        }
                        .onChange(of: selectedItems) { _, items in
                            Task {
                                selectedImageData.removeAll()
                                for item in items {
                                    if let data = try? await item.loadTransferable(type: Data.self) {
                                        selectedImageData.append(data)
                                    }
                                }
                            }
                        }
                        
                        if !selectedImageData.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(0..<selectedImageData.count, id: \.self) { index in
                                        if let uiImage = UIImage(data: selectedImageData[index]) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    
                    // MARK: - AI-Assisted Analysis Card
                    aiAnalysisCard
                    
                    // MARK: - Submit Button
                    Button {
                        submitContribution()
                    } label: {
                        HStack {
                            if isAnalyzing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "arrow.up.circle.fill")
                                Text("Submit for Coordinator Verification")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(title.isEmpty ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(title.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Contribute")
            .sheet(isPresented: $showDetailSheet) {
                if let contribution = createdContribution {
                    NavigationStack {
                        ActivityDetailView(contribution: contribution)
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button("Done") {
                                        showDetailSheet = false
                                        selectedTab = 0 // Return to Home tab
                                    }
                                }
                            }
                    }
                }
            }
        }
    }
    
    // MARK: - AI Analysis Card
    private var aiAnalysisCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("AI-Assisted Analysis — Human Verification Required")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.purple)
                Spacer()
                if isAnalyzing {
                    ProgressView().scaleEffect(0.8)
                }
            }
            
            Text("AI can suggest. Humans verify. Only verified contributions count toward official impact.")
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Divider()
            
            if let analysis = analysis {
                if !analysis.predictedCategories.isEmpty {
                    Text("Suggested SDGs:")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(analysis.predictedCategories) { prediction in
                                let sdgNum = prediction.sdgId ?? 0
                                HStack(spacing: 6) {
                                    Image("SDG_\(sdgNum)")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 22, height: 22)
                                        .cornerRadius(4)
                                    Text("SDG \(sdgNum) • \(prediction.category)")
                                        .font(.caption.weight(.bold))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.purple.opacity(0.12))
                                .foregroundColor(.purple)
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                if analysis.metrics.hasMetrics {
                    Divider()
                    Text("Extracted Impact Metrics:")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(analysis.metrics.summaryList, id: \.self) { item in
                            Text(item)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.green)
                        }
                    }
                } else {
                    Text("Tip: Include quantities in text (e.g. '5 trees', '20 kg waste') for AI auto-extraction.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Start typing your activity title or description above to see live AI SDG mapping and metric extraction.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
    
    // MARK: - Run AI Analysis
    private func runAIAnalysis() {
        guard !title.isEmpty || !activityDescription.isEmpty else { return }
        isAnalyzing = true
        Task {
            let result = await ActivityIntelligenceProvider.shared.analyze(title: title, description: activityDescription)
            await MainActor.run {
                self.analysis = result
                self.selectedSDGIds = Set(result.predictedCategories.compactMap { $0.sdgId })
                self.isAnalyzing = false
            }
        }
    }
    
    // MARK: - Submit Contribution
    private func submitContribution() {
        let metrics = analysis?.metrics ?? ExtractedMetrics()
        let selectedStrings = selectedSDGIds.map { id in
            let sdg = sdgs.first(where: { $0.number == id })
            return "\(id): \(sdg?.title ?? "")"
        }
        
        let newEntry = Contribution(
            title: title,
            activityDescription: activityDescription,
            imagesData: selectedImageData.isEmpty ? nil : selectedImageData,
            date: Date(),
            selectedSDGs: selectedStrings,
            sdgIds: Array(selectedSDGIds).sorted(),
            location: location.isEmpty ? nil : location,
            status: .pending,
            treesPlanted: metrics.treesPlanted,
            wasteRecycledKg: metrics.wasteRecycledKg,
            energySavedKWh: metrics.energySavedKWh,
            waterSavedLiters: metrics.waterSavedLiters,
            peopleReached: metrics.peopleReached,
            volunteerHours: metrics.volunteerHours
        )
        
        modelContext.insert(newEntry)
        self.createdContribution = newEntry
        self.showDetailSheet = true
        
        // Reset Form
        title = ""
        activityDescription = ""
        selectedImageData = []
        selectedItems = []
        analysis = nil
    }
}
