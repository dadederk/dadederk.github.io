import Foundation
import Ignite

// MARK: - Data Aggregator for Apps

struct AppsData {
    let apps: [AppItem]
    
    static func loadContent() -> AppsData {
        return AppsMarkdownLoader.loadAppsContent()
    }
    
    // Helper struct for parsing markdown content
    struct AppContentItem {
        let title: String
        let subtitle: String?
        let description: String
        let nameOrigin: String?
        let imagePath: String?
        let imageDescription: String?
        let actions: [[String: String]]?
        let features: [[String: String]]?
        let supportText: String?
        let contactEmail: String?
        let date: Date
    }
}

struct AppItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let nameOrigin: String
    let imagePath: String
    let imageDescription: String
    let actions: [ActionItem]
    let features: [FeatureItem]
    let supportText: String
    let contactEmail: String
}

struct FeatureItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imagePath: String?
    let imageDescription: String?
}
