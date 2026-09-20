//
//  ViewSDGGoals.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI
import SwiftData

struct ViewSDGGoals: View {
    let sdgsList: [SDG] = sdgs
    @State private var expandedSDG: SDG?
    @Query private var allContributions: [Contribution]

    private var chunkedSDGs: [[SDG]] {
        stride(from: 0, to: sdgsList.count, by: 2).map {
            Array(sdgsList[$0..<min($0 + 2, sdgsList.count)])
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.rowSpacing) {
                ForEach(chunkedSDGs, id: \.first!.id) { row in
                    HStack(alignment: .top, spacing: Constants.columnSpacing) {
                        ForEach(row) { sdg in
                            let isExpanded = (expandedSDG?.id == sdg.id)
                            let isSqueezed = (expandedSDG != nil && row.contains(where: { $0.id == expandedSDG?.id }) && !isExpanded)
                            
                            let count = allContributions.filter { entry in
                                entry.status == .approved && entry.sdgNumbers.contains(sdg.number)
                            }.count

                            SDGGridItemView(
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
            .padding(.top, Constants.topPadding)
            .padding(.horizontal)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationDestination(for: SDG.self) { sdg in
            SDGDetailView(sdg: sdg)
        }
        .onDisappear {
            expandedSDG = nil
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

extension ViewSDGGoals {
    private enum Constants {
        static let rowSpacing: CGFloat = 12
        static let columnSpacing: CGFloat = 12
        static let topPadding: CGFloat = 16
    }
}

struct SDGGridItemView: View {
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
                    maxWidth: isSqueezed ? Constants.squeezedWidth : .infinity,
                    minHeight: isExpanded ? Constants.expandedHeight : (isSqueezed ? Constants.squeezedHeight : Constants.defaultHeight),
                    maxHeight: isExpanded ? Constants.expandedHeight : (isSqueezed ? Constants.squeezedHeight : Constants.defaultHeight)
                )
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [
                            .black.opacity(0.15),
                            .black.opacity(0.35)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(Constants.cornerRadius)

            VStack(alignment: .leading, spacing: 8) {

                Text("\(sdg.number)")
                    .font(.system(size: isSqueezed ? 28 : 35, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)
                    .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 1)

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: sdg.symbolName)
                        .font(.title3)
                        .imageScale(.medium)

                    Text(sdg.title)
                        .font(.headline)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {

                        Text(sdg.tagline)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(3)

                        NavigationLink(value: sdg) {
                            Text("Learn More")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(hex: sdg.colorHex))
                    }
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(isSqueezed ? 12 : 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: isExpanded ? Constants.expandedHeight : (isSqueezed ? Constants.squeezedHeight : Constants.defaultHeight))
        .frame(maxWidth: isSqueezed ? Constants.squeezedWidth : .infinity)
        .contentShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .scaleEffect(isExpanded ? 1.02 : 1.0)
        .shadow(
            color: .black.opacity(isExpanded ? 0.25 : 0.15),
            radius: isExpanded ? 12 : 8,
            y: isExpanded ? 6 : 4
        )
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: isExpanded)
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: isSqueezed)
        .onTapGesture {
            onTap()
        }
    }
}

extension SDGGridItemView {
    private enum Constants {
        static let defaultHeight: CGFloat = 140
        static let expandedHeight: CGFloat = 250
        static let squeezedHeight: CGFloat = 125
        static let squeezedWidth: CGFloat = 125
        static let cornerRadius: CGFloat = 14
    }
}
