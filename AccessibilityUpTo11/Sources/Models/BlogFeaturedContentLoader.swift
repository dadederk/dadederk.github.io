import Foundation

struct BlogFeaturedContent {
    let heading: String?
    let mentions: [FeaturedMention]
    let quotes: [FeaturedQuoteItem]
}

struct BlogFeaturedContentLoader {
    static func featuredContent(for path: String) -> BlogFeaturedContent? {
        let contentByPath = loadContentByPath()
        return contentByPath[path]
    }

    private static func loadContentByPath() -> [String: BlogFeaturedContent] {
        guard let url = getFeaturedContentURL() else {
            return [:]
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(BlogFeaturedContentJSON.self, from: data)

            var contentByPath: [String: BlogFeaturedContent] = [:]
            for entry in decoded.posts {
                contentByPath[entry.path] = BlogFeaturedContent(
                    heading: entry.heading,
                    mentions: entry.mentions.map { mention in
                        FeaturedMention(
                            title: mention.title,
                            target: mention.target
                        )
                    },
                    quotes: entry.quotes.map { quote in
                        FeaturedQuoteItem(
                            text: quote.text,
                            sourceTitle: quote.sourceTitle,
                            sourceTarget: quote.sourceTarget
                        )
                    }
                )
            }
            return contentByPath
        } catch {
            print("Error loading featured post content from \(url.path): \(error)")
            return [:]
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
