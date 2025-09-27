import Foundation
import Ignite

// MARK: - Resources Data Model

struct ResourcesData {
    let sections: [ResourceSection]
    
    static func loadContent() -> ResourcesData {
        return ResourcesMarkdownLoader.loadResources()
    }
}

struct ResourceSection {
    let title: String
    var subsections: [ResourceSubsection]
}

struct ResourceSubsection {
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
