#!/bin/bash

# Generate RSS feed for 365 Days iOS Accessibility
# Run this script after building the site with: swift run IgniteCLI build

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "📝 Generating 365 Days iOS Accessibility RSS feed..."

# Create temporary Swift script
cat > "$PROJECT_DIR/temp_rss_generator.swift" << 'EOF'
#!/usr/bin/env swift

import Foundation

struct Days365Data {
    let title: String
    let author: String
    let date: Date
    let tags: [String]
    let categories: [String]
    let content: String
    let excerpt: String
    let fileName: String
    let dayNumber: Int
    
    var path: String {
        "/365-days-ios-accessibility/\(fileName.replacingOccurrences(of: ".md", with: ""))"
    }
}

func loadPosts() -> [Days365Data] {
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
            if let post = parseMarkdownFile(at: fileURL) {
                posts.append(post)
            }
        }
    } catch {
        print("Error loading posts: \(error)")
    }
    
    return posts.sorted { $0.dayNumber > $1.dayNumber }
}

func parseMarkdownFile(at url: URL) -> Days365Data? {
    guard let content = try? String(contentsOf: url, encoding: .utf8) else {
        return nil
    }
    
    let fileName = url.lastPathComponent
    let dayNumber = extractDayNumber(from: fileName)
    
    let components = content.components(separatedBy: "---")
    guard components.count >= 3 else {
        return nil
    }
    
    let frontmatter = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
    let markdownContent = components[2...].joined(separator: "---").trimmingCharacters(in: .whitespacesAndNewlines)
    
    var title = ""
    var author = ""
    var date = Date()
    var tags: [String] = []
    var categories: [String] = []
    
    let lines = frontmatter.components(separatedBy: .newlines)
    for line in lines {
        let components = line.components(separatedBy: ": ")
        if components.count >= 2 {
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
                tags = parseArrayValue(value)
            case "categories":
                categories = parseArrayValue(value)
            default:
                break
            }
        }
    }
    
    let excerpt = generateExcerpt(from: markdownContent)
    
    return Days365Data(
        title: title,
        author: author,
        date: date,
        tags: tags,
        categories: categories,
        content: markdownContent,
        excerpt: excerpt,
        fileName: fileName,
        dayNumber: dayNumber
    )
}

func extractDayNumber(from fileName: String) -> Int {
    let pattern = "day-(\\d+)\\.md"
    let regex = try? NSRegularExpression(pattern: pattern)
    let range = NSRange(location: 0, length: fileName.count)
    
    if let match = regex?.firstMatch(in: fileName, options: [], range: range),
       let dayRange = Range(match.range(at: 1), in: fileName) {
        return Int(fileName[dayRange]) ?? 0
    }
    
    return 0
}

func parseArrayValue(_ value: String) -> [String] {
    let trimmed = value.trimmingCharacters(in: .whitespaces)
    
    if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
        let inner = String(trimmed.dropFirst().dropLast())
        return inner.components(separatedBy: "\",\"")
            .map { $0.replacingOccurrences(of: "\"", with: "") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    return trimmed.components(separatedBy: ",")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
}

func generateExcerpt(from content: String) -> String {
    var cleanContent = content
    cleanContent = cleanContent.replacingOccurrences(of: #"!\[.*?\]\(.*?\)"#, with: "", options: .regularExpression)
    cleanContent = cleanContent.replacingOccurrences(of: #"\[.*?\]\(.*?\)"#, with: "", options: .regularExpression)
    
    let firstParagraph = cleanContent.components(separatedBy: .newlines)
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .first ?? ""
    
    let trimmed = firstParagraph.trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard trimmed.count > 200 else { return trimmed }
    
    let index = trimmed.index(trimmed.startIndex, offsetBy: 200)
    return String(trimmed[..<index]) + "..."
}

func xmlEscape(_ string: String) -> String {
    return string
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
        .replacingOccurrences(of: "'", with: "&#39;")
}

func generateRSSFeed(for posts: [Days365Data]) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    let buildDate = dateFormatter.string(from: Date())
    let lastBuildDate = posts.first?.date ?? Date()
    let lastBuildDateString = dateFormatter.string(from: lastBuildDate)
    
    var rss = """
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
<channel>
<title>#365DaysIOSAccessibility</title>
<link>https://accessibilityupto11.com/365-days-ios-accessibility</link>
<description>A year-long journey exploring iOS accessibility, one day at a time. Each post shares practical insights, tips, and techniques to make your iOS apps more accessible.</description>
<language>en-us</language>
<copyright>Copyright © Daniel Devesa Derksen-Staats</copyright>
<managingEditor>daniel@accessibilityupto11.com (Daniel Devesa Derksen-Staats)</managingEditor>
<webMaster>daniel@accessibilityupto11.com (Daniel Devesa Derksen-Staats)</webMaster>
<pubDate>\(buildDate)</pubDate>
<lastBuildDate>\(lastBuildDateString)</lastBuildDate>
<generator>Ignite Static Site Generator</generator>
<image>
<url>https://accessibilityupto11.com/Images/Site/Global/LogoShare.png</url>
<title>#365DaysIOSAccessibility</title>
<link>https://accessibilityupto11.com/365-days-ios-accessibility</link>
<width>144</width>
<height>144</height>
</image>
<atom:link href="https://accessibilityupto11.com/365-days-feed.rss" rel="self" type="application/rss+xml" />

"""
    
    for post in posts.prefix(50) {
        let pubDate = dateFormatter.string(from: post.date)
        let guid = "https://accessibilityupto11.com\(post.path)"
        
        let cleanTitle = xmlEscape(post.title)
        let cleanExcerpt = xmlEscape(post.excerpt)
        let categories = post.tags.map { "<category>\(xmlEscape($0))</category>" }.joined(separator: "\n")
        
        rss += """
<item>
<title>\(cleanTitle)</title>
<link>\(guid)</link>
<description>\(cleanExcerpt)</description>
<author>daniel@accessibilityupto11.com (Daniel Devesa Derksen-Staats)</author>
<pubDate>\(pubDate)</pubDate>
<guid isPermaLink="true">\(guid)</guid>
\(categories)
</item>

"""
    }
    
    rss += """
</channel>
</rss>
"""
    
    return rss
}

// Main execution
let posts = loadPosts()
let rssContent = generateRSSFeed(for: posts)

// Write RSS file to Build directory
let fileManager = FileManager.default
let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
let buildDirectory = currentDirectory.appendingPathComponent("Build")
let rssFile = buildDirectory.appendingPathComponent("365-days-feed.rss")

do {
    try rssContent.write(to: rssFile, atomically: true, encoding: .utf8)
    print("✅ Successfully generated RSS feed: \(posts.count) posts")
} catch {
    print("❌ Error writing RSS feed: \(error)")
    exit(1)
}
EOF

# Run the Swift script
cd "$PROJECT_DIR"
swift temp_rss_generator.swift

# Clean up
rm temp_rss_generator.swift

echo "🎉 RSS feed generation complete!"
