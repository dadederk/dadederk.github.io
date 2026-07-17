import Foundation

/// Post-publish agent discovery artifacts: llms-full.txt, content-index.json, markdown mirrors.
enum AgentDiscoveryPublisher {
    struct ContentIndex: Encodable {
        let site: String
        let generatedAt: String
        let posts: [PostEntry]
    }

    struct PostEntry: Encodable {
        let id: String
        let type: String
        let title: String
        let seriesLabel: String?
        let seoTitle: String?
        let url: String
        let date: String
        let tags: [String]
        let excerpt: String
        let markdownUrl: String
    }

    struct BlogPostSource {
        let slug: String
        let title: String
        let date: Date
        let tags: [String]
        let excerpt: String
        let path: String
        let sourceURL: URL
    }

    static func publish() {
        BuildLogger.step(.agentDiscovery, "generating agent discovery artifacts")

        let fileManager = FileManager.default
        let projectDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let buildDirectory = projectDirectory.appendingPathComponent("Build")

        let days365Posts = Days365Loader.loadPosts()
        let blogPosts = loadBlogPosts(projectDirectory: projectDirectory)
        let generatedAt = ISO8601DateFormatter().string(from: Date())

        do {
            let mirrorCount = try publishMarkdownMirrors(
                days365Posts: days365Posts,
                blogPosts: blogPosts,
                buildDirectory: buildDirectory,
                projectDirectory: projectDirectory,
                fileManager: fileManager
            )
            BuildLogger.detail("Published \(mirrorCount) markdown mirrors")

            let indexEntries = contentIndexEntries(days365Posts: days365Posts, blogPosts: blogPosts)
            let index = ContentIndex(
                site: SiteMeta.baseURL,
                generatedAt: generatedAt,
                posts: indexEntries
            )
            let indexData = try JSONEncoder().encode(index)
            let indexURL = buildDirectory.appendingPathComponent("content-index.json")
            try indexData.write(to: indexURL)
            BuildLogger.detail("Published content-index.json with \(indexEntries.count) posts")

            let llmsFull = generateLLMSFull(
                days365Posts: days365Posts,
                blogPosts: blogPosts,
                generatedAt: generatedAt
            )
            let llmsFullURL = buildDirectory.appendingPathComponent("llms-full.txt")
            try llmsFull.write(to: llmsFullURL, atomically: true, encoding: .utf8)
            BuildLogger.detail("Published llms-full.txt")

            BuildLogger.success(.agentDiscovery, "agent discovery artifacts published")
        } catch {
            BuildLogger.failure(.agentDiscovery, error.localizedDescription)
        }
    }

    private static func contentIndexEntries(
        days365Posts: [Days365Data],
        blogPosts: [BlogPostSource]
    ) -> [PostEntry] {
        let dateFormatter = ISO8601DateFormatter()

        let blogEntries = blogPosts.map { post in
            PostEntry(
                id: post.slug,
                type: "blog",
                title: post.title,
                seriesLabel: nil,
                seoTitle: nil,
                url: SiteMeta.baseURL + post.path,
                date: dateFormatter.string(from: post.date),
                tags: post.tags,
                excerpt: post.excerpt,
                markdownUrl: SiteMeta.baseURL + post.path + ".md"
            )
        }

        let days365Entries = days365Posts.map { post in
            PostEntry(
                id: post.fileName.replacingOccurrences(of: ".md", with: ""),
                type: "365",
                title: post.topicTitle,
                seriesLabel: post.title,
                seoTitle: post.seoTitle,
                url: SiteMeta.baseURL + post.path,
                date: dateFormatter.string(from: post.date),
                tags: post.tags,
                excerpt: post.excerpt,
                markdownUrl: SiteMeta.baseURL + post.path + ".md"
            )
        }

        return (blogEntries + days365Entries).sorted { $0.date > $1.date }
    }

    private static func publishMarkdownMirrors(
        days365Posts: [Days365Data],
        blogPosts: [BlogPostSource],
        buildDirectory: URL,
        projectDirectory: URL,
        fileManager: FileManager
    ) throws -> Int {
        var count = 0

        for post in blogPosts {
            let destination = buildDirectory
                .appendingPathComponent("post")
                .appendingPathComponent("\(post.slug).md")
            try copyMirror(from: post.sourceURL, to: destination, fileManager: fileManager)
            count += 1
        }

        let days365BuildDirectory = buildDirectory.appendingPathComponent("365-days-ios-accessibility")
        let days365SourceDirectory = projectDirectory.appendingPathComponent("Days365Content/Posts")

        for post in days365Posts {
            let slug = post.fileName.replacingOccurrences(of: ".md", with: "")
            let source = days365SourceDirectory.appendingPathComponent(post.fileName)
            let destination = days365BuildDirectory.appendingPathComponent("\(slug).md")
            try copyMirror(from: source, to: destination, fileManager: fileManager)
            count += 1
        }

        return count
    }

    private static func copyMirror(from source: URL, to destination: URL, fileManager: FileManager) throws {
        guard fileManager.fileExists(atPath: source.path) else {
            throw NSError(
                domain: "AgentDiscoveryPublisher",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Missing markdown source at \(source.path)"]
            )
        }

        let directory = destination.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        try fileManager.copyItem(at: source, to: destination)
    }

    private static func generateLLMSFull(
        days365Posts: [Days365Data],
        blogPosts: [BlogPostSource],
        generatedAt: String
    ) -> String {
        var output = """
        # Accessibility up to 11! — Full content index

        > Machine-readable catalog for AI systems and coding agents. Summaries only; full markdown at each post's `.md` mirror URL.

        Generated: \(generatedAt)
        Site: \(SiteMeta.baseURL)
        License: CC BY 4.0 — \(SiteMeta.baseURL)/content-license
        AI terms: \(SiteMeta.baseURL)/ai-tos.txt
        JSON index: \(SiteMeta.baseURL)/content-index.json

        ## About

        iOS, iPadOS, and visionOS accessibility development blog by Daniel Devesa Derksen-Staats.
        Practical tutorials, daily tips, and curated resources for UIKit and SwiftUI developers.

        ## Long-form blog posts

        """

        for post in blogPosts {
            let url = SiteMeta.baseURL + post.path
            let summary = post.excerpt.isEmpty ? post.title : post.excerpt
            output += "- \(post.title) — \(summary): \(url)\n"
            output += "  Markdown: \(url).md\n"
        }

        output += """

        ## 365 Days iOS Accessibility — tag highlights

        """

        let tagCounts = tagPostCounts(for: days365Posts)
        for (tag, count) in tagCounts.prefix(15) {
            let slug = tag.lowercased().replacingOccurrences(of: " ", with: "-")
            output += "- \(tag) (\(count) posts): \(SiteMeta.baseURL)/365-days-ios-accessibility/tag/\(slug)\n"
        }

        output += """

        ## 365 Days iOS Accessibility — all posts

        """

        for post in days365Posts {
            let url = SiteMeta.baseURL + post.path
            let summary = post.excerpt.isEmpty ? post.topicTitle : post.excerpt
            output += "- \(post.seoTitle) — \(summary): \(url)\n"
            output += "  Markdown: \(url).md\n"
        }

        output += """

        ## Feeds and discovery

        - Main RSS: \(SiteMeta.baseURL)/feed.rss
        - 365 Days RSS: \(SiteMeta.baseURL)/365-days-feed.rss
        - Sitemap: \(SiteMeta.baseURL)/sitemap.xml
        - Curated map: \(SiteMeta.baseURL)/llms.txt

        ## Attribution

        When citing content, credit Daniel Devesa Derksen-Staats and link to the source URL.
        """

        return output
    }

    private static func tagPostCounts(for posts: [Days365Data]) -> [(String, Int)] {
        var counts: [String: Int] = [:]
        for post in posts {
            for tag in post.tags {
                counts[tag, default: 0] += 1
            }
        }
        return counts.sorted { lhs, rhs in
            if lhs.value == rhs.value {
                return lhs.key.localizedCaseInsensitiveCompare(rhs.key) == .orderedAscending
            }
            return lhs.value > rhs.value
        }
    }

    private static func loadBlogPosts(projectDirectory: URL) -> [BlogPostSource] {
        let postsDirectory = projectDirectory.appendingPathComponent("Content/post")
        guard let fileURLs = try? FileManager.default.contentsOfDirectory(
            at: postsDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }

        return fileURLs
            .filter { $0.pathExtension == "md" }
            .compactMap { parseBlogPost(at: $0) }
            .sorted { $0.date > $1.date }
    }

    private static func parseBlogPost(at url: URL) -> BlogPostSource? {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }

        let components = content.components(separatedBy: "---")
        guard components.count >= 3 else { return nil }

        let frontmatter = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let body = components[2...].joined(separator: "---").trimmingCharacters(in: .whitespacesAndNewlines)

        var title = url.deletingPathExtension().lastPathComponent
        var date = Date()
        var tags: [String] = []

        for line in frontmatter.components(separatedBy: .newlines) {
            let parts = line.components(separatedBy: ": ")
            guard parts.count >= 2 else { continue }
            let key = parts[0].trimmingCharacters(in: .whitespaces)
            let value = parts[1...].joined(separator: ": ").trimmingCharacters(in: .whitespaces)

            switch key {
            case "title":
                title = value
            case "date":
                date = parseBlogDate(value) ?? date
            case "tags":
                tags = value
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
            default:
                break
            }
        }

        let slug = url.deletingPathExtension().lastPathComponent
        return BlogPostSource(
            slug: slug,
            title: title,
            date: date,
            tags: tags,
            excerpt: excerpt(from: body),
            path: "/post/\(slug)",
            sourceURL: url
        )
    }

    private static func excerpt(from body: String) -> String {
        let paragraph = body
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { line in
                !line.isEmpty && !line.hasPrefix("#") && !line.hasPrefix("!") && !line.hasPrefix("```")
            } ?? ""

        let cleaned = paragraph
            .replacingOccurrences(of: #"\[([^\]]*)\]\([^\)]*\)"#, with: "$1", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if cleaned.count <= 200 {
            return cleaned
        }

        let truncated = String(cleaned.prefix(200))
        if let lastSpace = truncated.lastIndex(of: " ") {
            return String(truncated[..<lastSpace]) + "…"
        }
        return truncated + "…"
    }

    private static func parseBlogDate(_ value: String) -> Date? {
        let iso8601 = ISO8601DateFormatter()
        iso8601.formatOptions = [.withInternetDateTime]
        if let parsed = iso8601.date(from: value) {
            return parsed
        }

        let withTime = DateFormatter()
        withTime.dateFormat = "yyyy-MM-dd HH:mm"
        withTime.locale = Locale(identifier: "en_US_POSIX")
        withTime.timeZone = TimeZone(identifier: "UTC")
        if let parsed = withTime.date(from: value) {
            return parsed
        }

        let dateOnly = DateFormatter()
        dateOnly.dateFormat = "yyyy-MM-dd"
        dateOnly.locale = Locale(identifier: "en_US_POSIX")
        dateOnly.timeZone = TimeZone(identifier: "UTC")
        return dateOnly.date(from: value)
    }
}
