//
//  YourContributionView.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI
import SwiftData

struct YourContributionView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Contribution.date, order: .reverse) private var entries: [Contribution]
    
    @State private var showAdd = false
    @State private var showFilterSheet = false
    @State private var selectedFilters: Set<String> = []
        
    private var filteredEntries: [Contribution] {
        guard !selectedFilters.isEmpty else {
            return entries
        }
        
        let activeNumbers = Set(
            sdgs.filter { selectedFilters.contains($0.title) }
                .map { "\($0.number)" }
        )
        
        return entries.filter { entry in
            entry.selectedSDGs.contains { sdgString in
                guard let prefix = sdgString.split(separator: ":").first else { return false }
                return activeNumbers.contains(String(prefix))
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if filteredEntries.isEmpty {
                    emptyStateView
                } else {
                    contributionList
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .refreshable {
            await refreshStatuses()
        }
        .onAppear {
            Task {
                await refreshStatuses()
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showAdd = true
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.bold)
                }
                
                Button {
                    showFilterSheet = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            AddEntryView()
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterView(
                selectedFilters: $selectedFilters,
                isPresented: $showFilterSheet
            )
        }
    }
    
    private var contributionList: some View {
        ForEach(filteredEntries) { entry in
            NavigationLink(destination: ActivityDetailView(contribution: entry)) {
                ContributionViewCards(entry: entry)
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button(role: .destructive) {
                    context.delete(entry)
                } label: {
                    Label("Delete Contribution", systemImage: "trash")
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 44))
                .foregroundStyle(.green)
            
            Text("No Contributions Logged Yet")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Tap the '+' button at the top right to log a sustainability action for coordinator verification.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
        .padding(.horizontal, 16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(20)
        .padding(.horizontal, 16)
    }
    
    private func refreshStatuses() async {
        for entry in entries {
            if let result = try? await APIService.shared.fetchContributionStatus(id: entry.id) {
                await MainActor.run {
                    entry.status = result.status
                    if let note = result.note {
                        entry.reviewerNotes = note
                    }
                }
            }
        }
    }
}

struct FilterView: View {
    @Binding var selectedFilters: Set<String>
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            List {
                Button("Clear All Filters") {
                    selectedFilters.removeAll()
                }
                .foregroundColor(.red)
                
                ForEach(sdgs) { sdg in
                    Button {
                        if selectedFilters.contains(sdg.title) {
                            selectedFilters.remove(sdg.title)
                        } else {
                            selectedFilters.insert(sdg.title)
                        }
                    } label: {
                        HStack {
                            Text("Goal \(sdg.number): \(sdg.title)")
                                .foregroundStyle(.primary)
                            Spacer()
                            if selectedFilters.contains(sdg.title) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter by SDG Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
