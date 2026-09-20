//
//  ExploreSDGsView.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI
import SwiftData

struct ExploreSDGsView: View {
    let sdgsList: [SDG] = sdgs
    @State private var expandedSDG: SDG?
    @Query private var allContributions: [Contribution]
    
    private var chunkedSDGs: [[SDG]] {
        stride(from: 0, to: sdgsList.count, by: 2).map {
            Array(sdgsList[$0..<min($0 + 2, sdgsList.count)])
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(chunkedSDGs, id: \.first!.id) { row in
                        HStack(alignment: .top, spacing: 12) {
                            ForEach(row) { sdg in
                                let isExpanded = (expandedSDG?.id == sdg.id)
                                let isSqueezed = (expandedSDG != nil && row.contains(where: { $0.id == expandedSDG?.id }) && !isExpanded)
                                
                                let count = allContributions.filter { entry in
                                    entry.status == .approved && entry.sdgNumbers.contains(sdg.number)
                                }.count

                                SDGGridCardView(
                                    sdg: sdg,
                                    isExpanded: isExpanded,
                                    isSqueezed: isSqueezed,
                                    contributionCount: count
                                ) {
                                    toggleExpansion(for: sdg)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Explore UN SDGs")
            .navigationDestination(for: SDG.self) { sdg in
                SDGDetailView(sdg: sdg)
            }
        }
    }

    private func toggleExpansion(for sdg: SDG) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0.1)) {
            if expandedSDG?.id == sdg.id {
                expandedSDG = nil
            } else {
                expandedSDG = sdg
            }
        }
    }
}

struct SDGGridCardView: View {
    let sdg: SDG
    let isExpanded: Bool
    let isSqueezed: Bool
    let contributionCount: Int
    let onTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(sdg.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(
                    minWidth: 0,
                    maxWidth: isSqueezed ? 125 : .infinity,
                    minHeight: isExpanded ? 250 : (isSqueezed ? 125 : 140),
                    maxHeight: isExpanded ? 250 : (isSqueezed ? 125 : 140)
                )
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [.black.opacity(0.15), .black.opacity(0.45)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(14)

            VStack(alignment: .leading, spacing: 6) {
                Text("\(sdg.number)")
                    .font(.system(size: isSqueezed ? 26 : 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 1)

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: sdg.symbolName)
                        .font(.title3)
                    Text(sdg.title)
                        .font(.headline)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)

                if isExpanded {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(sdg.tagline)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(3)

                        NavigationLink(value: sdg) {
                            Text("Learn More")
                                .font(.subheadline.weight(.bold))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(hex: sdg.colorHex))
                    }
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(isSqueezed ? 10 : 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: isExpanded ? 250 : (isSqueezed ? 125 : 140))
        .frame(maxWidth: isSqueezed ? 125 : .infinity)
        .contentShape(RoundedRectangle(cornerRadius: 14))
        .onTapGesture {
            onTap()
        }
    }
}
