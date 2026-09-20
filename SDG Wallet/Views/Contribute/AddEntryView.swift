//
//  AddEntryView.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI
import SwiftData
import PhotosUI

enum ContributeStep {
    case write
    case confirmSDGs
    case review
}

struct AddEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Step state
    @State private var currentStep: ContributeStep = .write
    
    // User Inputs
    @State private var title: String = ""
    @State private var activityDescription: String = ""
    @State private var location: String = ""
    @State private var taggedPerson: String = ""
    @State private var showLocationPrompt: Bool = false
    @State private var showTagPrompt: Bool = false
    
    // Photo selection
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImageData: [Data] = []
    @State private var showCamera: Bool = false
    
    // AI Analysis State
    @State private var analysis: ActivityAnalysis?
    @State private var isAnalyzing: Bool = false
    @State private var selectedSDGIds: Set<Int> = []
    @State private var showWhyTheseGoals: Bool = false

    private var formattedCurrentDate: String {
        Date().formatted(.dateTime.day().month(.wide).year())
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        switch currentStep {
                        case .write:
                            writeStepView
                        case .confirmSDGs:
                            confirmSDGsStepView
                        case .review:
                            reviewStepView
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, currentStep == .write ? 100 : 40)
                }
                .background(Color(uiColor: .systemBackground))
                
                // Floating Bottom Toolbar on Step 1
                if currentStep == .write {
                    floatingToolbar
                        .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .alert("Add Location", isPresented: $showLocationPrompt) {
                TextField("e.g. Campus Library Ground", text: $location)
                Button("OK") { }
                Button("Cancel", role: .cancel) { }
            }
            .alert("Tag People", isPresented: $showTagPrompt) {
                TextField("e.g. Sustainability Club Team", text: $taggedPerson)
                Button("OK") { }
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $showCamera) {
                CameraPicker(imageData: $selectedImageData)
            }
        }
    }
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        switch currentStep {
        case .write:
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .font(.body)
                .foregroundColor(.primary)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") {
                    runAIAndProceed()
                }
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(Color(uiColor: .secondarySystemBackground))
                .foregroundColor(title.trimmingCharacters(in: .whitespaces).isEmpty ? .secondary : .primary)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            
        case .confirmSDGs:
            ToolbarItem(placement: .navigation) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        currentStep = .write
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Confirm SDGs")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        currentStep = .review
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(Circle())
                }
            }
            
        case .review:
            ToolbarItem(placement: .navigation) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        currentStep = .confirmSDGs
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Review Entry")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveEntry()
                }
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color(uiColor: .secondarySystemBackground))
                .foregroundColor(.primary)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - Step 1: Write Step View
    private var writeStepView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(formattedCurrentDate)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Title
            TextField("Title", text: $title)
                .font(.system(size: 32, weight: .bold))
                .textFieldStyle(.plain)
            
            Divider()
                .padding(.bottom, 4)
            
            // Description
            TextField("Start writing...", text: $activityDescription, axis: .vertical)
                .font(.body)
                .lineLimit(5...15)
                .textFieldStyle(.plain)
            
            // Photo Requirement Banner
            if selectedImageData.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "camera.fill")
                    Text("Photo proof is required for portal submission.")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.orange)
                .padding(.vertical, 8)
            }
            
            // Attached Images Carousel
            if !selectedImageData.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<selectedImageData.count, id: \.self) { index in
                            if let uiImage = UIImage(data: selectedImageData[index]) {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 140, height: 140)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    
                                    Button {
                                        selectedImageData.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(6)
                                            .background(Color.black.opacity(0.65))
                                            .clipShape(Circle())
                                    }
                                    .padding(8)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
            
            // Optional Badges (Location / Tagged)
            if !location.isEmpty || !taggedPerson.isEmpty {
                HStack(spacing: 8) {
                    if !location.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                            Text(location)
                        }
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.green.opacity(0.12))
                        .foregroundColor(.green)
                        .clipShape(Capsule())
                    }
                    
                    if !taggedPerson.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "tag.fill")
                            Text(taggedPerson)
                        }
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.12))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    // MARK: - Floating Toolbar
    private var floatingToolbar: some View {
        HStack(spacing: 28) {
            Button {
                showCamera = true
            } label: {
                Image(systemName: "camera")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 5,
                matching: .images
            ) {
                Image(systemName: "photo.on.rectangle")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            .onChange(of: selectedItems) { _, items in
                Task {
                    for item in items {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            if !selectedImageData.contains(data) {
                                selectedImageData.append(data)
                            }
                        }
                    }
                    selectedItems.removeAll()
                }
            }
            
            Button {
                showLocationPrompt = true
            } label: {
                Image(systemName: location.isEmpty ? "paperplane" : "paperplane.fill")
                    .font(.title3)
                    .foregroundColor(location.isEmpty ? .primary : .green)
            }
            
            Button {
                showTagPrompt = true
            } label: {
                Image(systemName: taggedPerson.isEmpty ? "tag" : "tag.fill")
                    .font(.title3)
                    .foregroundColor(taggedPerson.isEmpty ? .primary : .blue)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(
            Capsule()
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 6)
        )
    }
    
    // MARK: - Step 2: Confirm SDGs View
    private var confirmSDGsStepView: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Suggested SDGs
            VStack(alignment: .leading, spacing: 12) {
                Text("Suggested SDGs")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                let suggestedList = suggestedSDGs
                
                if suggestedList.isEmpty {
                    Text("No automatic match. Select your SDG goals below.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                        ForEach(suggestedList) { sdg in
                            suggestedSDGCard(sdg: sdg)
                        }
                    }
                    
                    // Why These Goals Dropdown
                    Button {
                        withAnimation {
                            showWhyTheseGoals.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: showWhyTheseGoals ? "chevron.up" : "chevron.down")
                            Text("Why These Goals?")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                    }
                    
                    if showWhyTheseGoals {
                        VStack(alignment: .leading, spacing: 6) {
                            if let preds = analysis?.predictedCategories, !preds.isEmpty {
                                ForEach(preds) { p in
                                    Text("• **\(p.category)**: \(p.explanation)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                Text("Suggested based on key action words in your title and description.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(12)
                        .background(Color.blue.opacity(0.08))
                        .cornerRadius(12)
                    }
                }
            }
            
            // Additional SDGs
            VStack(alignment: .leading, spacing: 12) {
                Text("Additional SDGs")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                let additionalList = sdgs.filter { sdg in
                    !suggestedSDGs.contains(where: { $0.id == sdg.id })
                }
                
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                    ForEach(additionalList) { sdg in
                        additionalSDGCard(sdg: sdg)
                    }
                }
            }
        }
    }
    
    private var suggestedSDGs: [SDG] {
        guard let preds = analysis?.predictedCategories, !preds.isEmpty else {
            return []
        }
        let ids = preds.compactMap { $0.sdgId }
        return sdgs.filter { ids.contains($0.number) }
    }
    
    private func suggestedSDGCard(sdg: SDG) -> some View {
        let isSelected = selectedSDGIds.contains(sdg.number)
        
        return Button {
            if isSelected {
                selectedSDGIds.remove(sdg.number)
            } else {
                selectedSDGIds.insert(sdg.number)
            }
        } label: {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image("SDG_\(sdg.number)")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.blue)
                            .background(Circle().fill(Color.white).padding(2))
                            .padding(6)
                    } else {
                        Image(systemName: "circle")
                            .font(.system(size: 18))
                            .foregroundColor(Color.gray.opacity(0.35))
                            .background(Circle().fill(Color.white.opacity(0.85)).padding(2))
                            .padding(6)
                    }
                }
                
                Text(sdg.title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
            }
            .padding(12)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private func additionalSDGCard(sdg: SDG) -> some View {
        let isSelected = selectedSDGIds.contains(sdg.number)
        
        return Button {
            if isSelected {
                selectedSDGIds.remove(sdg.number)
            } else {
                selectedSDGIds.insert(sdg.number)
            }
        } label: {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image("SDG_\(sdg.number)")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.blue)
                            .background(Circle().fill(Color.white).padding(2))
                            .padding(6)
                    } else {
                        Image(systemName: "circle")
                            .font(.system(size: 18))
                            .foregroundColor(Color.gray.opacity(0.35))
                            .background(Circle().fill(Color.white.opacity(0.85)).padding(2))
                            .padding(6)
                    }
                }
                
                Text(sdg.title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
            }
            .padding(12)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Step 3: Review Step View
    private var reviewStepView: some View {
        VStack(alignment: .leading, spacing: 18) {
            
            // Selected SDGs
            VStack(alignment: .leading, spacing: 10) {
                Text("Selected SDGs")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                if selectedSDGIds.isEmpty {
                    Text("None selected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Array(selectedSDGIds).sorted(), id: \.self) { num in
                                ZStack(alignment: .topTrailing) {
                                    Image("SDG_\(num)")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    
                                    Button {
                                        selectedSDGIds.remove(num)
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(4)
                                            .background(Color.black.opacity(0.7))
                                            .clipShape(Circle())
                                    }
                                    .padding(4)
                                }
                            }
                        }
                    }
                }
            }
            
            // Title & Description
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if !activityDescription.isEmpty {
                    Text(activityDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            // Photo Attachments
            if !selectedImageData.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<selectedImageData.count, id: \.self) { index in
                            if let uiImage = UIImage(data: selectedImageData[index]) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 140)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                    }
                }
            }
            
            // Location and Date
            HStack(spacing: 8) {
                Text(formattedCurrentDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !location.isEmpty {
                    Text("•")
                        .foregroundColor(.secondary)
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 4)
        }
    }
    
    // MARK: - Actions
    private func runAIAndProceed() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isAnalyzing = true
        Task {
            let result = await ActivityIntelligenceProvider.shared.analyze(title: title, description: activityDescription)
            await MainActor.run {
                self.analysis = result
                self.selectedSDGIds = Set(result.predictedCategories.compactMap { $0.sdgId })
                self.isAnalyzing = false
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.currentStep = .confirmSDGs
                }
            }
        }
    }
    
    private func saveEntry() {
        let metrics = analysis?.metrics ?? ExtractedMetrics()
        let selectedStrings = selectedSDGIds.map { id in
            let sdg = sdgs.first(where: { $0.number == id })
            return "\(id): \(sdg?.title ?? "")"
        }
        
        let fileHash = selectedImageData.first.map { CryptoUtils.sha256(for: $0) }
        let s3Key: String? = selectedImageData.isEmpty ? nil : "evidence/\(UUID().uuidString).jpg"
        
        let newEntry = Contribution(
            title: title,
            activityDescription: activityDescription,
            imagesData: selectedImageData.isEmpty ? nil : selectedImageData,
            date: Date(),
            selectedSDGs: selectedStrings,
            sdgIds: Array(selectedSDGIds).sorted(),
            location: location.isEmpty ? nil : location,
            taggedPeople: taggedPerson.isEmpty ? [] : [taggedPerson],
            status: .pending,
            treesPlanted: metrics.treesPlanted,
            wasteRecycledKg: metrics.wasteRecycledKg,
            energySavedKWh: metrics.energySavedKWh,
            waterSavedLiters: metrics.waterSavedLiters,
            peopleReached: metrics.peopleReached,
            volunteerHours: metrics.volunteerHours,
            primaryS3Key: s3Key,
            fileHashSha256: fileHash
        )
        
        modelContext.insert(newEntry)
        
        Task {
            _ = try? await APIService.shared.submitContribution(newEntry)
        }
        
        dismiss()
    }
}

// MARK: - Camera Picker Representable
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var imageData: [Data]
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage,
               let data = uiImage.jpegData(compressionQuality: 0.8) {
                parent.imageData.append(data)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
