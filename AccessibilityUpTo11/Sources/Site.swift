import Foundation
import Ignite

@main
struct AccessibilityUpTo11Website {
    static func main() async {
        var site = AccessibilityUpTo11Site()

        do {
            try await site.publish()
            
            // Generate custom RSS feed for 365 Days iOS Accessibility
            await generate365DaysRSSFeed()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Generate RSS feed for 365 Days iOS Accessibility content
    static func generate365DaysRSSFeed() async {
        print("📝 Generating 365 Days iOS Accessibility RSS feed...")
        
        let posts = Days365Loader.loadPosts()
        let rssContent = generateRSSFeedContent(for: Array(posts.prefix(50)))
        
        let fileManager = FileManager.default
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let buildDirectory = currentDirectory.appendingPathComponent("Build")
        let rssFile = buildDirectory.appendingPathComponent("365-days-feed.rss")
        
        do {
            try rssContent.write(to: rssFile, atomically: true, encoding: .utf8)
            print("✅ Successfully generated RSS feed: \(posts.count) posts")
        } catch {
            print("❌ Error writing RSS feed: \(error)")
        }
    }
    
    /// Generate RSS XML content for 365 days posts
    static func generateRSSFeedContent(for posts: [Days365Data]) -> String {
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
        
        for post in posts {
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
    
    /// XML escape helper function
    static func xmlEscape(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}

struct AccessibilityUpTo11Site: Site {    
    var name = "Accessibility up to 11!"
    var titleSuffix = " #365DaysIOSAccessibility"
    var url = URL(static: "https://accessibilityupto11.com")
    var builtInIconsEnabled = true
    var description = "iOS accessibility development blog and resources for developers who want to make their apps accessible to everyone."
    
    var author = "Daniel Devesa Derksen-Staats"
    var language = Language.english
    var timeZone = TimeZone.current
    
    var homePage = Home()
    var layout = MainLayout()
    var tagPage = MyTagPage()
    
    // Disable HTML prettifying to fix code block issues
    var prettifyHTML = false
    
    // Custom themes for old paper aesthetic
    var lightTheme: (any Theme)? = AccessibilityUpTo11Theme()
    var darkTheme: (any Theme)? = AccessibilityUpTo11DarkTheme()
    
    // Enable RSS feed for the blog with user's specified configuration
    var feedConfiguration = FeedConfiguration(
        mode: .full,
        contentCount: 1000,
        path: "/feed.rss",
        image: FeedConfiguration.FeedImage(
            url: "https://accessibilityupto11.com/Images/Site/Global/LogoShare.png",
            width: 144,
            height: 144
        )
    )
    
    // Enable syntax highlighting for code blocks
    var syntaxHighlighterConfiguration: SyntaxHighlighterConfiguration {
        .init(
            languages: [.swift, .objectiveC, .bash],
            lineNumberVisibility: .hidden,
            firstLineNumber: 1,
            shouldWrapLines: false
        )
    }
    
    // Custom article layout for blog posts
    var articlePages: [any ArticlePage] {
        BlogPostLayout()
    }
    
    // Static pages
    var staticPages: [any StaticPage] {
        var pages: [any StaticPage] = [
            Blog(),
            Days365(),
            About(),
            Apps(),
            MoreContent(),
            // App pages using UniversalAppPage template
            UniversalAppPage(appIdentifier: "mestre", pageType: .main),
            UniversalAppPage(appIdentifier: "mestre", pageType: .terms),
            UniversalAppPage(appIdentifier: "mestre", pageType: .privacy),
            UniversalAppPage(appIdentifier: "xarra", pageType: .main),
            UniversalAppPage(appIdentifier: "xarra", pageType: .terms),
            UniversalAppPage(appIdentifier: "xarra", pageType: .privacy)
        ]
        
        // Add all 365 days posts and tag pages
        pages.append(contentsOf: Days365StaticPages.generateAllPages())
        
        return pages
    }
    
}
