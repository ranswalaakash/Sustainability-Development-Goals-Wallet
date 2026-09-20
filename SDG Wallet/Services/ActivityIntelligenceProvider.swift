//
//  ActivityIntelligenceProvider.swift
//  SDG Wallet
//
//  Created by Aakash Singh Ranswal on 20/09/26.
//

import Foundation

struct CategoryPrediction: Codable, Hashable, Identifiable {
    var id: String { category }
    var category: String
    var explanation: String
    var sdgId: Int?
}

struct ExtractedMetrics: Codable, Equatable {
    var treesPlanted: Int = 0
    var wasteRecycledKg: Double = 0.0
    var energySavedKWh: Double = 0.0
    var waterSavedLiters: Double = 0.0
    var peopleReached: Int = 0
    var volunteerHours: Double = 0.0
    
    var hasMetrics: Bool {
        treesPlanted > 0 || wasteRecycledKg > 0 || energySavedKWh > 0 || waterSavedLiters > 0 || peopleReached > 0 || volunteerHours > 0
    }
    
    var summaryList: [String] {
        var items: [String] = []
        if treesPlanted > 0 { items.append("🌳 \(treesPlanted) trees planted") }
        if wasteRecycledKg > 0 { items.append("♻️ \(Int(wasteRecycledKg)) kg waste recycled") }
        if energySavedKWh > 0 { items.append("⚡️ \(Int(energySavedKWh)) kWh energy saved") }
        if waterSavedLiters > 0 { items.append("💧 \(Int(waterSavedLiters)) L water saved") }
        if peopleReached > 0 { items.append("👥 \(peopleReached) people reached") }
        if volunteerHours > 0 { items.append("⏱️ \(Int(volunteerHours)) volunteer hrs") }
        return items
    }
}

struct ActivityAnalysis: Codable {
    var predictedCategories: [CategoryPrediction]
    var metrics: ExtractedMetrics
    var overview: String
    var confidenceScore: Double // 0.0 to 1.0
}

actor ActivityIntelligenceProvider {
    static let shared = ActivityIntelligenceProvider()
    
    private init() { }
    
    func warmup() async { }
    
    func analyze(title: String, description: String) async -> ActivityAnalysis {
        let text = "\(title) \(description)"
        let categories = SDGRuleClassifier.analyzeCategories(text: text)
        let metrics = ExtractedMetricAnalyzer.extract(text: text)
        
        let confidence = categories.isEmpty ? 0.4 : 0.92
        let overviewText = categories.isEmpty
            ? "No direct SDG signal was found. Please select the SDGs manually."
            : "AI extracted \(categories.count) SDG target\(categories.count > 1 ? "s" : "") and quantitative impact metrics. Awaiting coordinator verification."
        
        return ActivityAnalysis(
            predictedCategories: categories,
            metrics: metrics,
            overview: overviewText,
            confidenceScore: confidence
        )
    }
}

// MARK: - Extracted Metric Analyzer
enum ExtractedMetricAnalyzer {
    static func extract(text: String) -> ExtractedMetrics {
        let normalized = text.lowercased()
        var metrics = ExtractedMetrics()
        
        // Extract trees
        if let match = firstMatch(in: normalized, regex: #"(\d+)\s*(?:sapling|saplings|tree|trees|plant|plants)"#) {
            metrics.treesPlanted = Int(match) ?? 0
        }
        
        // Extract waste recycled (kg)
        if let match = firstMatch(in: normalized, regex: #"(\d+(?:\.\d+)?)\s*(?:kg|kilogram|kilograms)?\s*(?:of\s*)?(?:waste|plastic|recycling|trash|garbage)"#) {
            metrics.wasteRecycledKg = Double(match) ?? 0
        }
        
        // Extract energy saved (kWh)
        if let match = firstMatch(in: normalized, regex: #"(\d+(?:\.\d+)?)\s*(?:kwh|kilowatt|kilowatt-hours|units?)\s*(?:saved|reduced|of energy)?"#) {
            metrics.energySavedKWh = Double(match) ?? 0
        }
        
        // Extract water saved (liters)
        if let match = firstMatch(in: normalized, regex: #"(\d+(?:\.\d+)?)\s*(?:l|liter|liters|litre|litres|gallons)\s*(?:of\s*)?water"#) {
            metrics.waterSavedLiters = Double(match) ?? 0
        }
        
        // Extract people reached / participants
        if let match = firstMatch(in: normalized, regex: #"(\d+)\s*(?:people|students|participants|individuals|residents|persons)"#) {
            metrics.peopleReached = Int(match) ?? 0
        }
        
        // Extract volunteer hours
        if let match = firstMatch(in: normalized, regex: #"(\d+(?:\.\d+)?)\s*(?:hr|hrs|hour|hours)\s*(?:of\s*)?(?:volunteering|work|service)?"#) {
            metrics.volunteerHours = Double(match) ?? 0
        }
        
        return metrics
    }
    
    private static func firstMatch(in text: String, regex: String) -> String? {
        guard let range = text.range(of: regex, options: .regularExpression) else { return nil }
        let substring = String(text[range])
        let digits = substring.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()
        return digits.isEmpty ? nil : digits
    }
}

// MARK: - SDG Rule Classifier
enum SDGRuleClassifier {
    static func analyzeCategories(text: String) -> [CategoryPrediction] {
        let normalizedText = text
            .lowercased()
            .replacingOccurrences(of: "-", with: " ")

        var matches: [Int: SDGMatch] = [:]

        func has(_ words: String...) -> Bool {
            words.contains { normalizedText.contains($0) }
        }

        func countMatches(_ words: [String]) -> Int {
            words.filter { normalizedText.contains($0) }.count
        }

        func add(_ category: String, sdgId: Int, explanation: String, score: Int) {
            guard score > 0 else { return }

            if var existing = matches[sdgId] {
                existing.score += score
                if !existing.reasons.contains(explanation) {
                    existing.reasons.append(explanation)
                }
                matches[sdgId] = existing
            } else {
                matches[sdgId] = SDGMatch(
                    category: category,
                    sdgId: sdgId,
                    score: score,
                    reasons: [explanation]
                )
            }
        }

        for rule in SDGRulesData.rules {
            let score = countMatches(rule.signals)
            add(rule.category, sdgId: rule.sdgId, explanation: rule.explanation, score: score)
        }

        if has("tree", "trees", "plant", "planted", "plantation", "green drive", "sapling") {
            add("Climate Action", sdgId: 13, explanation: "Tree planting supports carbon sequestration and climate action.", score: 3)
            add("Life on Land", sdgId: 15, explanation: "Planting trees directly restores terrestrial ecosystems and terrestrial biodiversity.", score: 4)
        }

        if has("cleanup", "clean up", "cleaning", "cleaned", "cleanliness", "waste", "litter") && has("campus", "community", "park", "street", "public space", "neighbourhood", "neighborhood") {
            add("Sustainable Cities", sdgId: 11, explanation: "Cleaning shared public spaces improves safety and livability of communities.", score: 3)
            add("Responsible Consumption", sdgId: 12, explanation: "Waste collection promotes responsible consumption and proper waste management.", score: 2)
        }

        if has("beach", "river", "lake", "ocean", "pond", "water body") && has("cleanup", "clean up", "plastic", "waste") {
            add("Life Below Water", sdgId: 14, explanation: "Removing plastic waste near aquatic environments protects marine life.", score: 4)
            add("Responsible Consumption", sdgId: 12, explanation: "Waste cleanup addresses plastic pollution at the source.", score: 2)
        }

        if has("solar", "renewable", "led", "electricity", "energy saving", "save electricity", "power") {
            add("Clean Energy", sdgId: 7, explanation: "Energy efficiency and clean energy adoption support SDG 7.", score: 3)
            add("Climate Action", sdgId: 13, explanation: "Reducing energy emissions directly counters climate change.", score: 2)
        }

        let predictions = matches.values
            .sorted { left, right in
                if left.score == right.score {
                    return left.sdgId < right.sdgId
                }
                return left.score > right.score
            }
            .prefix(5)
            .map { match in
                CategoryPrediction(
                    category: match.category,
                    explanation: match.reasons.prefix(2).joined(separator: " "),
                    sdgId: match.sdgId
                )
            }

        return Array(predictions)
    }
}

private struct SDGRulesData {
    struct Rule {
        let sdgId: Int
        let category: String
        let signals: [String]
        let explanation: String
    }

    static let rules: [Rule] = [
        Rule(
            sdgId: 1,
            category: "No Poverty",
            signals: ["poverty", "poor", "homeless", "shelter", "blanket", "clothes donation", "basic needs"],
            explanation: "This initiative provides essential resources to individuals experiencing hardship."
        ),
        Rule(
            sdgId: 2,
            category: "Zero Hunger",
            signals: ["food", "meal", "hunger", "ration", "food bank", "community kitchen", "meals donated"],
            explanation: "This activity supports hunger relief and food security."
        ),
        Rule(
            sdgId: 3,
            category: "Good Health",
            signals: ["health", "medical", "blood donation", "wellbeing", "well being", "mental health", "fitness", "hygiene"],
            explanation: "This activity promotes health, wellness, and disease prevention."
        ),
        Rule(
            sdgId: 4,
            category: "Quality Education",
            signals: ["teach", "learn", "education", "mentor", "awareness", "workshop", "training", "class", "books", "library"],
            explanation: "This activity enhances access to learning, skill development, and awareness."
        ),
        Rule(
            sdgId: 5,
            category: "Gender Equality",
            signals: ["gender", "women", "girls", "menstrual", "equality", "equal opportunity", "mother", "chores", "care work"],
            explanation: "This activity supports equal opportunity and gender empowerment."
        ),
        Rule(
            sdgId: 6,
            category: "Clean Water",
            signals: ["water", "sanitation", "leak", "rainwater", "clean water", "save water", "water conservation"],
            explanation: "This activity conserves clean water and improves sanitation."
        ),
        Rule(
            sdgId: 7,
            category: "Clean Energy",
            signals: ["solar", "energy", "electricity", "power saving", "led", "renewable", "clean energy"],
            explanation: "This activity promotes renewable energy and energy efficiency."
        ),
        Rule(
            sdgId: 8,
            category: "Decent Work",
            signals: ["job", "employment", "entrepreneur", "skill", "fair wage", "decent work", "livelihood"],
            explanation: "This activity supports skill-building and decent employment opportunities."
        ),
        Rule(
            sdgId: 9,
            category: "Innovation",
            signals: ["innovation", "infrastructure", "technology", "prototype", "research", "engineering", "app"],
            explanation: "This activity fosters innovation and resilient infrastructure."
        ),
        Rule(
            sdgId: 10,
            category: "Reduced Inequalities",
            signals: ["inclusion", "disability", "accessible", "inequality", "marginalized", "underprivileged"],
            explanation: "This activity promotes social inclusion and equal opportunity for all."
        ),
        Rule(
            sdgId: 11,
            category: "Sustainable Cities",
            signals: ["campus", "community", "cleanup", "public space", "transport", "neighbourhood", "park", "street"],
            explanation: "This activity improves local public spaces and community sustainability."
        ),
        Rule(
            sdgId: 12,
            category: "Responsible Consumption",
            signals: ["recycle", "recycling", "waste", "plastic", "reuse", "compost", "segregation", "upcycle"],
            explanation: "This activity reduces waste generation and encourages recycling."
        ),
        Rule(
            sdgId: 13,
            category: "Climate Action",
            signals: ["climate", "carbon", "co2", "emission", "bike", "bicycle", "plantation", "green drive"],
            explanation: "This activity actively reduces carbon emissions or promotes climate resilience."
        ),
        Rule(
            sdgId: 14,
            category: "Life Below Water",
            signals: ["ocean", "river", "lake", "beach", "marine", "fish", "water body"],
            explanation: "This activity protects aquatic environments and prevents marine pollution."
        ),
        Rule(
            sdgId: 15,
            category: "Life on Land",
            signals: ["tree", "trees", "plant", "planted", "plantation", "garden", "forest", "biodiversity", "wildlife"],
            explanation: "This activity restores land ecosystems, plants trees, and protects biodiversity."
        ),
        Rule(
            sdgId: 16,
            category: "Peace & Justice",
            signals: ["justice", "peace", "rights", "safety", "governance", "legal awareness"],
            explanation: "This activity supports peaceful communities and accountable institutions."
        ),
        Rule(
            sdgId: 17,
            category: "Partnerships",
            signals: ["partnership", "collaboration", "ngo", "club", "team", "community partner", "volunteer group"],
            explanation: "This activity leverages cross-sector partnerships for shared impact."
        )
    ]
}

private struct SDGMatch {
    let category: String
    let sdgId: Int
    var score: Int
    var reasons: [String]
}
