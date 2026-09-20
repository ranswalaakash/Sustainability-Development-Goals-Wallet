//
//  SDG_WalletApp.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI
import SwiftData

@main
struct SDG_WalletApp: App {
    private let container: ModelContainer

    init() {
        self.container = Self.makeModelContainer()
        Task.detached(priority: .background) {
            await ActivityIntelligenceProvider.shared.warmup()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
    
    private static func makeModelContainer() -> ModelContainer {
        let schema = Schema([
            Contribution.self
        ])
        
        do {
            return try ModelContainer(for: schema)
        } catch {
            resetLocalStore()
            return try! ModelContainer(for: schema)
        }
    }
    
    private static func resetLocalStore() {
        guard let supportURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else { return }
        
        let storeFiles = [
            "default.store",
            "default.store-shm",
            "default.store-wal"
        ]
        
        for fileName in storeFiles {
            let url = supportURL.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: url)
        }
    }
}
