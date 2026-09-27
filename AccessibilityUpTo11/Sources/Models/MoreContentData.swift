import Foundation
import Ignite

// MARK: - Data Aggregator for More Content

struct MoreContentData {
    let publications: [PublicationItem]
    let talks: [TalkItem]
    let podcasts: [PodcastItem]
    
    /// Cards shown in each About section. The rest live on the category page.
    static let aboutSectionLimit = 3

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
