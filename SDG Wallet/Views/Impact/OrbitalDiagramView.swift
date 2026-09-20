//
//  OrbitalDiagramView.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI

struct OrbitalDiagramView<Content: View>: View {
    let snapshots: [ImpactSnapshot]
    let orbitRadius: CGFloat
    let pCircleSize: CGFloat
    let centralHubSize: CGFloat
    let isInteractive: Bool
    
    @ViewBuilder let centralContent: Content
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.12), lineWidth: 1.5)
                .frame(width: orbitRadius * 2, height: orbitRadius * 2)

            centralContent
               .frame(width: centralHubSize, height: centralHubSize)
               .background(
                    Circle()
                       .fill(Color(uiColor: .secondarySystemGroupedBackground))
                       .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
                )
            
            ForEach(snapshots) { snapshot in
                Group {
                    if isInteractive {
                        NavigationLink(destination: FivePDetailView(snapshot: snapshot)) {
                            PCircleThumbnail(snapshot: snapshot, isStatic: false)
                        }
                        .buttonStyle(.plain)
                    } else {
                        PCircleThumbnail(snapshot: snapshot, isStatic: true)
                    }
                }
                .frame(width: pCircleSize, height: pCircleSize)
                .offset(calculateOffset(for: snapshot.type))
            }
        }
        .frame(height: orbitRadius * 2 + pCircleSize)
    }
    
    private func calculateOffset(for type: FivePType) -> CGSize {
        let index = FivePType.allCases.firstIndex(of: type) ?? 0
        let angle = (Double(index) * 72.0) - 90.0
        let radians = angle * .pi / 180
        return CGSize(width: orbitRadius * cos(CGFloat(radians)),
                      height: orbitRadius * sin(CGFloat(radians)))
    }
}

struct PCircleThumbnail: View {
    let snapshot: ImpactSnapshot
    
    @State private var animatedTrim: CGFloat = 0
    var isStatic: Bool = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color(hex: snapshot.info.colorHex).opacity(0.2), radius: 8, x: 0, y: 4)
            
            Circle()
                .stroke(Color(hex: snapshot.info.colorHex).opacity(0.2), lineWidth: 7.0)
            
            Circle()
                .trim(from: 0, to: isStatic ? CGFloat(snapshot.score / 100) : animatedTrim)
                .stroke(
                    Color(hex: snapshot.info.colorHex),
                    style: StrokeStyle(lineWidth: 8.0, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 3) {
                Image(systemName: snapshot.info.symbolName)
                    .font(.system(size: 18, weight: .semibold))
                
                Text(snapshot.info.title)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text("\(Int(snapshot.score))%")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            .foregroundColor(Color(hex: snapshot.info.colorHex))
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.2)) {
                animatedTrim = CGFloat(snapshot.score / 100)
            }
        }
        .onChange(of: snapshot.score) { _, newScore in
            withAnimation(.easeOut(duration: 1.2)) {
                animatedTrim = CGFloat(newScore / 100)
            }
        }
    }
}
