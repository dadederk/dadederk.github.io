import Foundation
import Ignite

// MARK: - Shared Types for More Content

struct ActionItem {
    let title: String
    let target: String
    let style: String // "primary" or "secondary"
}

struct PublicationItem {
    let title: String
    let subtitle: String?
    let description: String
    let publisher: String
    let imagePath: String
    let imageDescription: String
    let actions: [ActionItem]
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
