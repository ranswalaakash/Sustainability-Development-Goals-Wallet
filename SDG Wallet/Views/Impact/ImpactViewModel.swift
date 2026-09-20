//
//  ImpactViewModel.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
class ImpactViewModel: ObservableObject {
    @Published var snapshots: [ImpactSnapshot] = []
    @Published var sdgDistributions: [Int: Double] = [:]
    
    @Published var totalActivitiesLogged: Int = 0
    @Published var totalVerifiedActivities: Int = 0
    @Published var totalSDGHits: Int = 0
    @Published var totalSDGsCovered: Int = 0
    @Published var sdgCounts: [Int: Int] = [:]
    
    // Aggregated Metrics
    @Published var verifiedTreesPlanted: Int = 0
    @Published var verifiedWasteRecycledKg: Double = 0.0
    @Published var verifiedEnergySavedKWh: Double = 0.0
    @Published var verifiedWaterSavedLiters: Double = 0.0
    @Published var verifiedPeopleReached: Int = 0
    @Published var verifiedVolunteerHours: Double = 0.0
    
    private func roundToWhole(_ value: Double) -> Double {
        value.rounded()
    }
    
    func calculateImpact(from contributions: [Contribution]) {
        totalActivitiesLogged = contributions.count
        
        // Filter strictly for VERIFIED contributions
        let verifiedContributions = contributions.filter { $0.status == .approved }
        totalVerifiedActivities = verifiedContributions.count
        
        // Sum verified quantitative metrics
        verifiedTreesPlanted = verifiedContributions.reduce(0) { $0 + $1.treesPlanted }
        verifiedWasteRecycledKg = verifiedContributions.reduce(0) { $0 + $1.wasteRecycledKg }
        verifiedEnergySavedKWh = verifiedContributions.reduce(0) { $0 + $1.energySavedKWh }
        verifiedWaterSavedLiters = verifiedContributions.reduce(0) { $0 + $1.waterSavedLiters }
        verifiedPeopleReached = verifiedContributions.reduce(0) { $0 + $1.peopleReached }
        verifiedVolunteerHours = verifiedContributions.reduce(0) { $0 + $1.volunteerHours }
        
        guard !verifiedContributions.isEmpty else {
            snapshots = []
            sdgDistributions = [:]
            totalSDGHits = 0
            totalSDGsCovered = 0
            sdgCounts = [:]
            return
        }
        
        let allLoggedSDGs = verifiedContributions.flatMap { $0.sdgNumbers }
        let totalHits = Double(allLoggedSDGs.count)
        guard totalHits > 0 else {
            snapshots = []
            sdgDistributions = [:]
            totalSDGHits = 0
            totalSDGsCovered = 0
            sdgCounts = [:]
            return
        }
        
        var counts: [Int: Int] = [:]
        for sdg in allLoggedSDGs {
            counts[sdg, default: 0] += 1
        }
        self.sdgCounts = counts
        self.totalSDGHits = allLoggedSDGs.count
        
        let uniqueLoggedSDGs = Set(allLoggedSDGs)
        self.totalSDGsCovered = uniqueLoggedSDGs.count
        
        var distribution: [Int: Double] = [:]
        for (sdg, hits) in counts {
            distribution[sdg] = Double(hits) / totalHits
        }
        self.sdgDistributions = distribution
        
        var generatedSnapshots: [ImpactSnapshot] = []
        
        for category in FivePInfo.all {
            let categorySDGs = category.sdgNumbers
            let categorySDGSet = Set(categorySDGs)
            let weightPerSDG = 1.0 / Double(categorySDGs.count)
            var weightedScore = 0.0
            
            for sdg in categorySDGs {
                if let hits = counts[sdg] {
                    let globalShare = Double(hits) / totalHits
                    weightedScore += globalShare * weightPerSDG
                }
            }
            
            let covered = uniqueLoggedSDGs.intersection(categorySDGSet)
            let activityCount = verifiedContributions.count { entry in
                !Set(entry.sdgNumbers).isDisjoint(with: categorySDGSet)
            }
            
            generatedSnapshots.append(
                ImpactSnapshot(
                    type: category.type,
                    score: roundToWhole(weightedScore * 100),
                    activityCount: activityCount,
                    coveredSDGs: Array(covered).sorted(),
                    info: category
                )
            )
        }
        
        self.snapshots = generatedSnapshots
    }
}
