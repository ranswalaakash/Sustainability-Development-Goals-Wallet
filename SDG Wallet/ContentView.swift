//
//  ContentView.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ViewSDGGoals()
                    .navigationTitle("UN SDGs")
            }
            .tabItem {
                Label("Explore", systemImage: "globe")
            }
            
            NavigationStack {
                YourContributionView()
                    .navigationTitle("My Contribution")
            }
            .tabItem {
                Label("Contribute", systemImage: "hands.sparkles")
            }
            
            NavigationStack {
                ImpactView()
                    .navigationTitle("Impact")
            }
            .tabItem {
                Label("Impact", systemImage: "leaf.fill")
            }
        }
        .tint(.green)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Contribution.self, inMemory: true)
}
