import Foundation
import Ignite

// MARK: - Data Aggregator for More Content

struct MoreContentData {
    let publications: [PublicationItem]
    let talks: [TalkItem]
    let podcasts: [PodcastItem]
    
    static func loadContent() -> MoreContentData {
        return MarkdownContentLoader.loadMoreContent()
    }
    
    // Helper struct for parsing markdown content
    struct ContentItem {
        let title: String
        let subtitle: String?
        let description: String
        let publisher: String?
        let imagePath: String?
        let imageDescription: String?
        let actions: [[String: String]]?
        let date: Date
    }
}
