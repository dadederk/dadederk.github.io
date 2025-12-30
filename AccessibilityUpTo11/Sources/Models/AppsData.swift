import Foundation
import Ignite

// MARK: - Data Aggregator for Apps

struct AppsData {
    let apps: [AppItem]
    
    static func loadContent() -> AppsData {
        return AppsJSONLoader.loadAppsContent()
    }
}

struct AppItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let subtitle: String
    let description: String
    let nameOrigin: String
    let imagePath: String
    let imageDescription: String
    let platforms: [String]
    let actions: [ActionItem]
    let featureGroups: [FeatureGroup]
    let features: [FeatureItem] // Keep for backward compatibility
    let accessibility: String?
    let whySection: String?
    let supportText: String
    let contactEmail: String
    
    init(id: UUID = UUID(), title: String, subtitle: String, description: String, nameOrigin: String, imagePath: String, imageDescription: String, platforms: [String], actions: [ActionItem], featureGroups: [FeatureGroup], features: [FeatureItem], accessibility: String?, whySection: String?, supportText: String, contactEmail: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.nameOrigin = nameOrigin
        self.imagePath = imagePath
        self.imageDescription = imageDescription
        self.platforms = platforms
        self.actions = actions
        self.featureGroups = featureGroups
        self.features = features
        self.accessibility = accessibility
        self.whySection = whySection
        self.supportText = supportText
        self.contactEmail = contactEmail
    }
}

struct FeatureGroup: Identifiable, Codable {
    let id: UUID
    let title: String
    let features: [FeatureItem]
    
    init(id: UUID = UUID(), title: String, features: [FeatureItem]) {
        self.id = id
        self.title = title
        self.features = features
    }
}

struct FeatureItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let imagePath: String?
    let imageDescription: String?
    
    init(id: UUID = UUID(), title: String, description: String, imagePath: String? = nil, imageDescription: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.imagePath = imagePath
        self.imageDescription = imageDescription
    }
}
