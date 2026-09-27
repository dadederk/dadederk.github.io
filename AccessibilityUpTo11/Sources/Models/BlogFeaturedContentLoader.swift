import Foundation

struct BlogFeaturedContent {
    let heading: String?
    let mentions: [FeaturedMention]
    let quotes: [FeaturedQuoteItem]
}

struct BlogFeaturedContentLoader {
    static func featuredContent(for path: String) -> BlogFeaturedContent? {
        loadContentByPath()[path]
    }

    static func featuredPublicationContent(matching title: String) -> BlogFeaturedContent? {
        loadPublicationsByTitle()[title]
    }

    private static func loadContentByPath() -> [String: BlogFeaturedContent] {
        guard let decoded = loadDecoded() else { return [:] }

        var contentByPath: [String: BlogFeaturedContent] = [:]
        for entry in decoded.posts {
            contentByPath[entry.path] = makeContent(
                heading: entry.heading,
                mentions: entry.mentions,
                quotes: entry.quotes
            )
        }
        return contentByPath
    }

    private static func loadPublicationsByTitle() -> [String: BlogFeaturedContent] {
        guard let decoded = loadDecoded() else { return [:] }

        var contentByTitle: [String: BlogFeaturedContent] = [:]
        for entry in decoded.publications ?? [] {
            contentByTitle[entry.title] = makeContent(
                heading: entry.heading,
                mentions: entry.mentions,
                quotes: entry.quotes
            )
        }
        return contentByTitle
    }

    private static func makeContent(
        heading: String?,
        mentions: [FeaturedMentionJSON],
        quotes: [FeaturedQuoteJSON]
    ) -> BlogFeaturedContent {
        BlogFeaturedContent(
            heading: heading,
            mentions: mentions.map { mention in
                FeaturedMention(
                    title: mention.title,
                    target: mention.target
                )
            },
            quotes: quotes.map { quote in
                FeaturedQuoteItem(
                    text: quote.text,
                    sourceTitle: quote.sourceTitle,
                    sourceTarget: quote.sourceTarget
                )
            }
        )
    }

    private static func loadDecoded() -> BlogFeaturedContentJSON? {
        guard let url = getFeaturedContentURL() else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(BlogFeaturedContentJSON.self, from: data)
        } catch {
            print("Error loading featured post content from \(url.path): \(error)")
            return nil
        }
    }

    private static func getFeaturedContentURL() -> URL? {
        let currentPath = FileManager.default.currentDirectoryPath

        let possiblePaths = [
            "\(currentPath)/ContentData/featured-posts.json",
            "\(currentPath)/AccessibilityUpTo11/ContentData/featured-posts.json",
            "ContentData/featured-posts.json",
            "AccessibilityUpTo11/ContentData/featured-posts.json"
        ]

        for path in possiblePaths {
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }

        print("Warning: Could not find featured-posts.json. Tried paths: \(possiblePaths)")
        return nil
    }
}

private struct BlogFeaturedContentJSON: Codable {
    let posts: [PostFeaturedContentJSON]
    let publications: [PublicationFeaturedContentJSON]?
}

private struct PublicationFeaturedContentJSON: Codable {
    let title: String
    let heading: String?
    let mentions: [FeaturedMentionJSON]
    let quotes: [FeaturedQuoteJSON]
}

private struct PostFeaturedContentJSON: Codable {
    let path: String
    let heading: String?
    let mentions: [FeaturedMentionJSON]
    let quotes: [FeaturedQuoteJSON]
}

private struct FeaturedMentionJSON: Codable {
    let title: String
    let target: String
}

private struct FeaturedQuoteJSON: Codable {
    let text: String
    let sourceTitle: String?
    let sourceTarget: String?
}
