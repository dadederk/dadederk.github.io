import Foundation
import Ignite

/// Data model for 365 Days iOS Accessibility content
struct Days365Data: Identifiable {
    var id: String { fileName }
    let title: String
    let author: String
    let date: Date
    let tags: [String]
    let categories: [String]
    let series: [String]
    let image: String?
    let content: String
    let excerpt: String
    let fileName: String
    let dayNumber: Int
    
    /// URL path for this 365 days post
    var path: String {
        "/365-days-ios-accessibility/\(fileName.replacingOccurrences(of: ".md", with: ""))"
    }
    
    /// Generate tag links for the post
    @MainActor func tagLinks() -> [any InlineElement] {
        return tags.map { tag in
            Link(tag, target: "/365-days-ios-accessibility/tag/\(tag.lowercased().replacingOccurrences(of: " ", with: "-"))")
                .class("badge", "bg-primary", "text-white", "rounded-pill", "me-2")
        }
    }
}

/// Loader for 365 Days iOS Accessibility markdown content
struct Days365Loader {
    private static var cachedPosts: [Days365Data]?
    
    /// Load all 365 days posts from markdown files
    static func loadPosts() -> [Days365Data] {
        if let cached = cachedPosts {
            return cached
        }
        
        let postsDirectory = "Days365Content/Posts"
        var posts: [Days365Data] = []
        
        do {
            let fileManager = FileManager.default
            let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
            let postsURL = currentDirectory.appendingPathComponent(postsDirectory)
            
            let fileURLs = try fileManager.contentsOfDirectory(at: postsURL, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == "md" }
                .sorted { $0.lastPathComponent < $1.lastPathComponent }
            
            for fileURL in fileURLs {
                if let post = Self.parseMarkdownFile(at: fileURL) {
                    posts.append(post)
                }
            }
        } catch {
            print("Error loading 365 days posts: \(error)")
        }
        
        // Sort by day number (descending - newest first)
        posts.sort { $0.dayNumber > $1.dayNumber }
        
        cachedPosts = posts
        return posts
    }
    
    /// Parse a single markdown file into Days365Data
    private static func parseMarkdownFile(at url: URL) -> Days365Data? {
        guard let content = try? String(contentsOf: url) else {
            return nil
        }
        
        let fileName = url.lastPathComponent
        
        // Extract day number from filename (e.g., "day-001.md" -> 1)
        let dayNumber = Self.extractDayNumber(from: fileName)
        
        // Split frontmatter and content
        let components = content.components(separatedBy: "---")
        guard components.count >= 3 else {
            return nil
        }
        
        let frontmatter = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let markdownContent = components[2...].joined(separator: "---").trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Parse frontmatter
        var title = ""
        var author = ""
        var date = Date()
        var tags: [String] = []
        var categories: [String] = []
        var series: [String] = []
        var image: String?
        
        let lines = frontmatter.components(separatedBy: .newlines)
        for line in lines {
            let components = line.components(separatedBy: ": ")
            guard components.count >= 2 else { continue }
            
            let key = components[0].trimmingCharacters(in: .whitespaces)
            let value = components[1...].joined(separator: ": ").trimmingCharacters(in: .whitespaces)
            
            switch key {
            case "title":
                title = value
            case "author":
                author = value
            case "date":
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime]
                date = formatter.date(from: value) ?? Date()
            case "tags":
                tags = Self.parseArrayValue(value)
            case "categories":
                categories = Self.parseArrayValue(value)
            case "series":
                series = Self.parseArrayValue(value)
            case "image":
                image = value
            default:
                break
            }
        }
        
        // Generate excerpt from content (first paragraph or first 200 characters)
        let excerpt = Self.generateExcerpt(from: markdownContent)
        
        return Days365Data(
            title: title,
            author: author,
            date: date,
            tags: tags,
            categories: categories,
            series: series,
            image: image,
            content: markdownContent,
            excerpt: excerpt,
            fileName: fileName,
            dayNumber: dayNumber
        )
    }
    
    /// Extract day number from filename
    private static func extractDayNumber(from fileName: String) -> Int {
        let pattern = "day-(\\d+)\\.md"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: fileName.count)
        
        if let match = regex?.firstMatch(in: fileName, options: [], range: range),
           let dayRange = Range(match.range(at: 1), in: fileName) {
            let dayString = String(fileName[dayRange])
            return Int(dayString) ?? 0
        }
        
        return 0
    }
    
    /// Parse array values from YAML (handles both comma-separated and bracket format)
    private static func parseArrayValue(_ value: String) -> [String] {
        let trimmedValue = value.trimmingCharacters(in: .whitespaces)
        
        // Handle bracket format: ["item1", "item2"]
        if trimmedValue.hasPrefix("[") && trimmedValue.hasSuffix("]") {
            let innerValue = String(trimmedValue.dropFirst().dropLast())
            return innerValue.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "\"")) }
                .filter { !$0.isEmpty }
        }
        
        // Handle comma-separated format: item1, item2, item3
        return trimmedValue.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    /// Generate excerpt from markdown content
    private static func generateExcerpt(from content: String) -> String {
        // Remove markdown images and links for cleaner excerpt
        var cleanContent = content
        
        // Remove image syntax ![alt](url)
        cleanContent = cleanContent.replacingOccurrences(
            of: "!\\[([^\\]]*)\\]\\([^\\)]*\\)",
            with: "",
            options: .regularExpression
        )
        
        // Remove link syntax [text](url) but keep the text
        cleanContent = cleanContent.replacingOccurrences(
            of: "\\[([^\\]]*)\\]\\([^\\)]*\\)",
            with: "$1",
            options: .regularExpression
        )
        
        // Get first paragraph or first 200 characters
        let paragraphs = cleanContent.components(separatedBy: "\n\n")
        if let firstParagraph = paragraphs.first, !firstParagraph.isEmpty {
            let trimmed = firstParagraph.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count <= 200 {
                return trimmed
            }
        }
        
        // Fallback to first 200 characters
        let trimmed = cleanContent.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= 200 {
            return trimmed
        }
        
        let index = trimmed.index(trimmed.startIndex, offsetBy: 200)
        return String(trimmed[..<index]) + "..."
    }
    
    /// Get posts by tag (searches both frontmatter tags and content hashtags)
    static func posts(withTag tag: String) -> [Days365Data] {
        return loadPosts().filter { post in
            // Check frontmatter tags
            let hasFrontmatterTag = post.tags.contains { $0.lowercased() == tag.lowercased() }
            
            // Check content hashtags
            let contentHashtags = extractHashtags(from: post.content)
            let hasContentHashtag = contentHashtags.contains { $0.lowercased() == tag.lowercased() }
            
            return hasFrontmatterTag || hasContentHashtag
        }
    }
    
    /// Get all unique tags (from frontmatter and content hashtags)
    static func allTags() -> [String] {
        let allPosts = loadPosts()
        var allTags: [String] = []
        
        // Add frontmatter tags
        allTags.append(contentsOf: allPosts.flatMap { $0.tags })
        
        // Add content hashtags
        allTags.append(contentsOf: allPosts.flatMap { extractHashtags(from: $0.content) })
        
        return Array(Set(allTags)).sorted()
    }
    
    /// Extract hashtags from markdown content
    static func extractHashtags(from content: String) -> [String] {
        let hashtagPattern = #"#([a-zA-Z0-9_-]+)"#
        
        guard let regex = try? NSRegularExpression(pattern: hashtagPattern, options: []) else {
            return []
        }
        
        let range = NSRange(location: 0, length: content.count)
        let matches = regex.matches(in: content, options: [], range: range)
        
        return matches.compactMap { match in
            if let hashtagRange = Range(match.range(at: 1), in: content) {
                return String(content[hashtagRange])
            }
            return nil
        }
    }
    
    /// Find post by filename (without extension)
    static func post(withFileName fileName: String) -> Days365Data? {
        return loadPosts().first { post in
            post.fileName.replacingOccurrences(of: ".md", with: "") == fileName
        }
    }
}
