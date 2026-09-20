//
//  ShareableImpactCard.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI

struct ShareableImpactCard: View {
    let snapshots: [ImpactSnapshot]
    let userName: String
    let totalActivities: Int
    
    private var allReachedSDGs: [Int] {
        Array(Set(snapshots.flatMap { $0.coveredSDGs })).sorted()
    }
    
    private var pillarsCoveredCount: Int {
        snapshots.filter { $0.score > 0 }.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            VStack(spacing: 12) {
                Text("VERIFIED IMPACT METRICS")
                    .font(.system(size: 15, weight: .bold))
                    .tracking(2)
                    .foregroundColor(Color.accentColor)
                
                VStack(spacing: 4) {
                    Text("\(userName)'s Verified Impact")
                    Text("UN Five Pillars of Sustainable Development")
                }
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            }
            .padding(.top, 40)
            
            Spacer(minLength: 30)
            
            // Diagram
            OrbitalDiagramView(
                snapshots: snapshots,
                orbitRadius: 125,
                pCircleSize: 85,
                centralHubSize: 140,
                isInteractive: false
            ) {
                VStack(spacing: 2) {
                    Text("\(totalActivities)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    
                    Text("VERIFIED\nINITIATIVES")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .tracking(1)
                }
            }
            
            Spacer()
            
            // Footer
            VStack(spacing: 20) {
                Divider()
                    .padding(.horizontal, 60)
                    .opacity(0.5)
                
                VStack(spacing: 12) {
                    Text("COVERED UN SDGs (\(allReachedSDGs.count)/17)")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(2)
                        .foregroundColor(.secondary)
                    
                    if allReachedSDGs.isEmpty {
                        Text("No verified contributions yet")
                            .font(.caption.italic())
                            .foregroundColor(.secondary)
                    } else {
                        HStack(spacing: 8) {
                            ForEach(allReachedSDGs.prefix(8), id: \.self) { num in
                                Image("SDG_\(num)")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text("SDG Wallet • Coordinator Verified")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
            .padding(.bottom, 40)
        }
        .frame(width: 390, height: 700)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}
