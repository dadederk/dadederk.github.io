import Foundation
import Ignite

// MARK: - Resources Data Model

struct ResourcesData {
    let sections: [ResourceSectionData]
    
    static func loadContent() -> ResourcesData {
        return ResourcesMarkdownLoader.loadResources()
    }
}

struct ResourceSectionData {
    let title: String
    var subsections: [ResourceSubsectionData]
}

struct ResourceSubsectionData {
    let title: String
    var items: [ResourceItem]
}

struct ResourceItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String?
    let url: String
    let author: String?
    let publisher: String?
    let markdownText: String
}
