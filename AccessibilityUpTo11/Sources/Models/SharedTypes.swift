import Foundation
import Ignite

// MARK: - Shared Types for More Content

struct ActionItem: Codable {
    let title: String
    let target: String
    let style: String // "primary" or "secondary"
}

struct FeaturedQuoteItem: Identifiable, Codable {
    let id: UUID
    let text: String
    let sourceTitle: String?
    let sourceTarget: String?
    let subject: String?
    let subjectTarget: String?

    init(
        id: UUID = UUID(),
        text: String,
        sourceTitle: String? = nil,
        sourceTarget: String? = nil,
        subject: String? = nil,
        subjectTarget: String? = nil
    ) {
        self.id = id
        self.text = text
        self.sourceTitle = sourceTitle
        self.sourceTarget = sourceTarget
        self.subject = subject
        self.subjectTarget = subjectTarget
    }
}

struct PublicationItem {
    let title: String
    let subtitle: String?
    let description: String
    let publisher: String
    let imagePath: String
    let imageDescription: String
    let actions: [ActionItem]
    let featuredContent: BlogFeaturedContent?
}

struct TalkItem {
    let title: String
    let subtitle: String
    let description: String
    let imagePath: String?
    let imageDescription: String?
    let actions: [ActionItem]
}

struct PodcastItem {
    let title: String
    let subtitle: String
    let description: String
    let imagePath: String?
    let imageDescription: String?
    let actions: [ActionItem]
}
