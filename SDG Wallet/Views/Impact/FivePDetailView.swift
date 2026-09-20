//
//  FivePDetailView.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI

struct FivePDetailView: View {
    let snapshot: ImpactSnapshot
    
    var themeColor: Color {
        Color(hex: snapshot.info.colorHex)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                headerHeroSection
                
                VStack(spacing: 6) {
                    Text(snapshot.info.title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    
                    Text(snapshot.info.shortTagline)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                
                progressSection
                insightSection
                goalsGridSection
            }
            .padding(.vertical, 24)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(snapshot.info.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerHeroSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(themeColor.opacity(0.12))
            
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(themeColor.opacity(0.2), lineWidth: 1)
            
            Image(systemName: snapshot.info.symbolName)
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .foregroundColor(themeColor)
        }
        .frame(height: 160)
        .padding(.horizontal)
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Verified Pillar Score")
                    .font(.headline)
                
                Spacer()
                
                Text("\(Int(snapshot.score))%")
                    .font(.title3.bold())
                    .foregroundColor(themeColor)
            }
            
            ProgressView(value: snapshot.score, total: 100)
                .tint(themeColor)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal)
    }
    
    private var insightSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What This Pillar Represents")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(snapshot.info.detailedDescription)
                .font(.body)
                .lineSpacing(6)
                .foregroundColor(.primary)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal)
    }
    
    private var goalsGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Target SDGs Involved")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 20) {
                ForEach(snapshot.info.sdgNumbers, id: \.self) { sdgNum in
                    let hasImpacted = snapshot.coveredSDGs.contains(sdgNum)
                    
                    VStack(spacing: 8) {
                        Image("SDG_\(sdgNum)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                            .cornerRadius(14)
                            .grayscale(hasImpacted ? 0 : 1)
                            .opacity(hasImpacted ? 1 : 0.6)
                        
                        Text("Goal \(sdgNum)")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(hasImpacted ? .primary : .secondary)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
