//
//  ContributionViewCards.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI
import SwiftData

struct ContributionViewCards: View {
    let entry: Contribution
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sdgIconGroup
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if !entry.activityDescription.isEmpty {
                    Text(entry.activityDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            HStack {
                Text(entry.date, format: .dateTime.weekday(.wide).day().month(.abbreviated))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Spacer()
                
                Text(statusText)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(statusBgColor)
                    .foregroundColor(statusFgColor)
                    .clipShape(Capsule())
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
    
    private var statusText: String {
        switch entry.status {
        case .pending:
            return "Saved on Device"
        case .approved:
            return "Verified"
        case .changesRequested:
            return "Changes Requested"
        case .rejected:
            return "Rejected"
        }
    }
    
    private var statusBgColor: Color {
        switch entry.status {
        case .pending:
            return Color(uiColor: .tertiarySystemFill)
        case .approved:
            return Color.green.opacity(0.15)
        case .changesRequested:
            return Color.orange.opacity(0.15)
        case .rejected:
            return Color.red.opacity(0.15)
        }
    }
    
    private var statusFgColor: Color {
        switch entry.status {
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
    
    @ViewBuilder
    private var sdgIconGroup: some View {
        if entry.selectedSDGs.isEmpty {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 38, height: 38)
                
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                    .font(.subheadline)
            }
        } else {
            HStack(spacing: 6) {
                ForEach(Array(entry.sdgNumbers.prefix(5)), id: \.self) { num in
                    Image("SDG_\(num)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 38, height: 38)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
    }
}
