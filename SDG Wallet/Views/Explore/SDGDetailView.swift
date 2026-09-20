//
//  SDGDetailView.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI
import AVFoundation

struct SDGDetailView: View {
    let sdg: SDG
    @State private var expandedIndex: Int?
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var isSpeakingEnabled = false
    
    private var sections: [SDGSection] {
        sectionsBySDG[String(sdg.number)] ?? []
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: sdg.colorHex).opacity(0.35),
                    Color(UIColor.systemBackground)
                ],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text(sdg.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.horizontal)

                    VStack(spacing: 14) {
                        ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                            ExpandableCard(
                                section: section,
                                isExpanded: expandedIndex == index,
                                accentColor: Color(hex: sdg.colorHex)
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                    expandedIndex = expandedIndex == index ? nil : index
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Goal \(sdg.number): \(sdg.title)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExpandableCard: View {
    let section: SDGSection
    let isExpanded: Bool
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            HStack {
                Text(section.title)
                    .font(.headline)
                    .foregroundColor(isExpanded ? accentColor : .primary)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(isExpanded ? accentColor : .secondary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 14) {
                    Text(section.summary)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(section.keyPoints, id: \.self) { point in
                            HStack(alignment: .top, spacing: 8) {
                                Circle()
                                    .fill(accentColor)
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 6)
                                
                                Text(point)
                                    .font(.subheadline)
                                    .foregroundColor(.primary.opacity(0.85))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isExpanded ? accentColor.opacity(0.12) : Color(UIColor.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isExpanded ? accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}
