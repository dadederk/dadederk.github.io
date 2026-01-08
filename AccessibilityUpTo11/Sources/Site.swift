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
            
            // Generate enhanced sitemap with lastmod and changefreq
            await generateEnhancedSitemap()
            
            // Generate image sitemap
            await generateImageSitemap()
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
    
    /// Generate enhanced sitemap with lastmod and changefreq
    static func generateEnhancedSitemap() async {
        print("🗺️ Generating enhanced sitemap...")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let currentDate = dateFormatter.string(from: Date())
        
        var sitemap = """
        <?xml version="1.0" encoding="UTF-8"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
        """
        
        // Add main pages
        let mainPages = [
            ("/", "1.0", "monthly"),
            ("/blog", "0.9", "monthly"),
            ("/about", "0.9", "monthly"),
            ("/resources", "0.9", "monthly"),
            ("/apps", "0.9", "monthly"),
            ("/365-days-ios-accessibility", "0.9", "weekly")
        ]
        
        for (path, priority, changefreq) in mainPages {
            sitemap += """
            <url>
                <loc>https://accessibilityupto11.com\(path)</loc>
                <lastmod>\(currentDate)</lastmod>
                <changefreq>\(changefreq)</changefreq>
                <priority>\(priority)</priority>
            </url>
            """
        }
        
        // Add app pages
        let appPages = [
            ("/apps/mestre", "0.9", "monthly"),
            ("/apps/mestre/terms", "0.8", "yearly"),
            ("/apps/mestre/privacy", "0.8", "yearly"),
            ("/apps/xarra", "0.9", "monthly"),
            ("/apps/xarra/terms", "0.8", "yearly"),
            ("/apps/xarra/privacy", "0.8", "yearly"),
            ("/apps/iMonstickers", "0.9", "monthly"),
            ("/apps/iMonstickers/terms", "0.8", "yearly"),
            ("/apps/iMonstickers/privacy", "0.8", "yearly")
        ]
        
        for (path, priority, changefreq) in appPages {
            sitemap += """
            <url>
                <loc>https://accessibilityupto11.com\(path)</loc>
                <lastmod>\(currentDate)</lastmod>
                <changefreq>\(changefreq)</changefreq>
                <priority>\(priority)</priority>
            </url>
            """
        }
        
        // Add blog posts - we'll get these from the site's articles
        // Note: We can't access @Environment here, so we'll skip blog posts for now
        // and add them manually or through a different approach
        
        // Add 365 Days posts
        let days365Posts = Days365Loader.loadPosts()
        for post in days365Posts {
            let postDate = dateFormatter.string(from: post.date)
            sitemap += """
            <url>
                <loc>https://accessibilityupto11.com\(post.path)</loc>
                <lastmod>\(postDate)</lastmod>
                <changefreq>monthly</changefreq>
                <priority>0.9</priority>
            </url>
            """
        }
        
        // Add pagination pages for 365 Days
        let totalPages = (days365Posts.count + 14) / 15 // 15 posts per page
        for page in 2...totalPages {
            sitemap += """
            <url>
                <loc>https://accessibilityupto11.com/365-days-ios-accessibility/page-\(page)</loc>
                <lastmod>\(currentDate)</lastmod>
                <changefreq>monthly</changefreq>
                <priority>0.9</priority>
            </url>
            """
        }
        
        // Add tag pages
        let allTags = Set(days365Posts.flatMap { $0.tags })
        for tag in allTags {
            let tagPath = "/365-days-ios-accessibility/tag/\(tag.lowercased().replacingOccurrences(of: " ", with: "-"))"
            sitemap += """
            <url>
                <loc>https://accessibilityupto11.com\(tagPath)</loc>
                <lastmod>\(currentDate)</lastmod>
                <changefreq>monthly</changefreq>
                <priority>0.9</priority>
            </url>
            """
        }
        
        sitemap += """
        </urlset>
        """
        
        // Write enhanced sitemap
        let fileManager = FileManager.default
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let buildDirectory = currentDirectory.appendingPathComponent("Build")
        let sitemapFile = buildDirectory.appendingPathComponent("sitemap.xml")
        
        do {
            try sitemap.write(to: sitemapFile, atomically: true, encoding: .utf8)
            let totalURLs = mainPages.count + appPages.count + days365Posts.count + totalPages - 1 + allTags.count
            print("✅ Successfully generated enhanced sitemap with \(totalURLs) URLs")
        } catch {
            print("❌ Error writing enhanced sitemap: \(error)")
        }
    }
    
    /// Generate image sitemap for better image SEO
    static func generateImageSitemap() async {
        print("🖼️ Generating image sitemap...")
        
        var imageSitemap = """
        <?xml version="1.0" encoding="UTF-8"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
                xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
        """
        
        // Add images from blog posts - we'll add these manually for now
        // since we can't access @Environment in this context
        
        // Add images from 365 Days posts
        let days365Posts = Days365Loader.loadPosts()
        for post in days365Posts {
            if let imagePath = post.image {
                let imageTitle = post.title
                let imageCaption = post.excerpt
                let imageURL = "https://accessibilityupto11.com\(imagePath)"
                
                imageSitemap += """
                <url>
                    <loc>https://accessibilityupto11.com\(post.path)</loc>
                    <image:image>
                        <image:loc>\(imageURL)</image:loc>
                        <image:title>\(xmlEscape(imageTitle))</image:title>
                        <image:caption>\(xmlEscape(imageCaption))</image:caption>
                    </image:image>
                </url>
                """
            }
        }
        
        // Add site logo and branding images
        let siteImages = [
            ("/Images/Site/Global/LogoShare.png", "Accessibility up to 11! Logo", "iOS accessibility development blog logo"),
            ("/Images/Site/Global/Logo.png", "Accessibility up to 11! Logo", "iOS accessibility development blog logo"),
            ("/Images/Site/Global/LogoDarkMode.png", "Accessibility up to 11! Logo - Dark Mode", "iOS accessibility development blog logo for dark mode")
        ]
        
        for (imagePath, title, caption) in siteImages {
            let imageURL = "https://accessibilityupto11.com\(imagePath)"
            imageSitemap += """
            <url>
                <loc>https://accessibilityupto11.com/</loc>
                <image:image>
                    <image:loc>\(imageURL)</image:loc>
                    <image:title>\(xmlEscape(title))</image:title>
                    <image:caption>\(xmlEscape(caption))</image:caption>
                </image:image>
            </url>
            """
        }
        
        imageSitemap += """
        </urlset>
        """
        
        // Write image sitemap
        let fileManager = FileManager.default
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let buildDirectory = currentDirectory.appendingPathComponent("Build")
        let imageSitemapFile = buildDirectory.appendingPathComponent("image-sitemap.xml")
        
        do {
            try imageSitemap.write(to: imageSitemapFile, atomically: true, encoding: .utf8)
            let imageCount = days365Posts.compactMap { $0.image }.count + siteImages.count
            print("✅ Successfully generated image sitemap with \(imageCount) images")
        } catch {
            print("❌ Error writing image sitemap: \(error)")
        }
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
            // Days365(), // Removed - now handled by Days365StaticPages.generateAllPages()
            About(),
            Resources(),
            Apps(),
            // App pages using UniversalAppPage template
            UniversalAppPage(appIdentifier: "mestre", pageType: .main),
            UniversalAppPage(appIdentifier: "mestre", pageType: .terms),
            UniversalAppPage(appIdentifier: "mestre", pageType: .privacy),
            UniversalAppPage(appIdentifier: "xarra", pageType: .main),
            UniversalAppPage(appIdentifier: "xarra", pageType: .terms),
            UniversalAppPage(appIdentifier: "xarra", pageType: .privacy),
            UniversalAppPage(appIdentifier: "iMonstickers", pageType: .main),
            UniversalAppPage(appIdentifier: "iMonstickers", pageType: .terms),
            UniversalAppPage(appIdentifier: "iMonstickers", pageType: .privacy)
        ]
        
        // Add all 365 days posts and tag pages
        pages.append(contentsOf: Days365StaticPages.generateAllPages())
        
        return pages
    }
    
}
