import Foundation
import Ignite

@main
struct AccessibilityUpTo11Website {
    static func main() async {
        var site = AccessibilityUpTo11Site()

        do {
            try ImageOptimizationPublisher.preflight()
            try ImageOptimizationPublisher.prepareForPublishing()
            BuildLogger.step(.build, "publishing Ignite site")
            try await site.publish()
            BuildLogger.success(.build, "site published")

            // Generate responsive image derivatives and rewrite image markup before
            // the remaining publishers validate or deploy the generated HTML.
            try ImageOptimizationPublisher.publish()

            // Ignite's nav current state is an exact path match. Mark Apps on child pages.
            let buildDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                .appendingPathComponent("Build", isDirectory: true)
            try NavigationSectionMarker.markBuiltSite(at: buildDirectory)
            
            // Generate custom RSS feed for 365 Days iOS Accessibility
            await generate365DaysRSSFeed()
            
            // Generate enhanced sitemap with lastmod and changefreq
            await generateEnhancedSitemap()
            
            // Generate image sitemap
            await generateImageSitemap()

            // Agent discovery artifacts (llms-full, content-index, markdown mirrors)
            try AgentDiscoveryPublisher.publish()

            // Ignite regenerates a minimal robots.txt; replace it with the curated Assets copy.
            try publishRobotsTxt()

            // Generate AASA file from the universal-link route configuration.
            try publishUniversalLinksAssociationFile()

            // Match GitHub Pages' final trailing-slash URLs throughout HTML.
            try CanonicalURLPublisher.publish(buildDirectory: buildDirectory)

            // Validate generated social metadata.
            try runSocialMetaValidation()

            BuildLogger.success(.build, "all post-publish tasks completed")
        } catch {
            BuildLogger.failure(.build, error.localizedDescription)
            exit(EXIT_FAILURE)
        }
    }
    
    /// Generate RSS feed for 365 Days iOS Accessibility content
    static func generate365DaysRSSFeed() async {
        BuildLogger.step(.rss, "loading 365 Days iOS Accessibility posts")
        
        let posts = Days365Loader.loadPosts()
        BuildLogger.detail("Loaded \(posts.count) posts; publishing all entries")

        BuildLogger.step(.rss, "generating 365 Days iOS Accessibility feed")
        let rssContent = generateRSSFeedContent(for: posts)
        
        let fileManager = FileManager.default
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let buildDirectory = currentDirectory.appendingPathComponent("Build")
        let rssFile = buildDirectory.appendingPathComponent("365-days-feed.rss")
        
        do {
            try rssContent.write(to: rssFile, atomically: true, encoding: .utf8)
            BuildLogger.success(.rss, "generated 365 Days feed with \(posts.count) posts")
        } catch {
            BuildLogger.failure(.rss, "could not write 365 Days feed: \(error.localizedDescription)")
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
        <link>https://accessibilityupto11.com/365-days-ios-accessibility/</link>
        <description>A year-long journey exploring iOS accessibility, one day at a time. Each post shares practical insights, tips, and techniques to make your iOS apps more accessible.</description>
        <language>en-us</language>
        <copyright>Copyright © Daniel Devesa Derksen-Staats. Licensed under CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/)</copyright>
        <managingEditor>hello@accessibilityUpTo11.com (Dani Devesa Derksen-Staats)</managingEditor>
        <webMaster>hello@accessibilityUpTo11.com (Dani Devesa Derksen-Staats)</webMaster>
        <pubDate>\(buildDate)</pubDate>
        <lastBuildDate>\(lastBuildDateString)</lastBuildDate>
        <generator>Ignite Static Site Generator</generator>
        <image>
        <url>https://accessibilityupto11.com/Images/Site/Global/LogoShare.png</url>
        <title>#365DaysIOSAccessibility</title>
        <link>https://accessibilityupto11.com/365-days-ios-accessibility/</link>
        <width>144</width>
        <height>144</height>
        </image>
        <atom:link href="https://accessibilityupto11.com/365-days-feed.rss" rel="self" type="application/rss+xml" />
        
        """
        
        for post in posts {
            let pubDate = dateFormatter.string(from: post.date)
            let guid = SiteMeta.absolutePageURL(for: post.path)
            
            let cleanTitle = xmlEscape(post.seoTitle)
            let cleanExcerpt = xmlEscape(post.excerpt)
            let categories = post.tags.map { "<category>\(xmlEscape($0))</category>" }.joined(separator: "\n")
            let enclosure: String
            if let imagePath = post.image {
                let absoluteImage = "https://accessibilityupto11.com\(imagePath)"
                enclosure = "<enclosure url=\"\(absoluteImage)\" type=\"image/png\" />"
            } else {
                enclosure = ""
            }
            
            rss += """
            <item>
            <title>\(cleanTitle)</title>
            <link>\(guid)</link>
            <description>\(cleanExcerpt)</description>
            <author>hello@accessibilityUpTo11.com (Dani Devesa Derksen-Staats)</author>
            <pubDate>\(pubDate)</pubDate>
            <guid isPermaLink="true">\(guid)</guid>
            \(categories)
            \(enclosure)
            </item>
            
            """
        }
        
        rss += """
        </channel>
        </rss>
        """
        
        return rss
    }
    
    /// Generate a sitemap whose URLs match the final served URLs and whose
    /// lastmod values come from content dates rather than build time.
    static func generateEnhancedSitemap() async {
        BuildLogger.step(.sitemap, "generating enhanced sitemap")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let blogPosts = BlogSitemapEntry.loadAll()
        let days365Posts = Days365Loader.loadPosts()
        let latestBlogDate = blogPosts.map(\.lastModifiedDate).max()
        let latestDaysDate = days365Posts.map { $0.modifiedDate ?? $0.date }.max()
        let latestSiteDate = (blogPosts.map(\.lastModifiedDate) + days365Posts.map { $0.modifiedDate ?? $0.date }).max()

        var sitemap = """
        <?xml version="1.0" encoding="UTF-8"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
        """

        func appendURL(path: String, lastModified: Date? = nil) {
            sitemap += """
            <url>
                <loc>\(SiteMeta.absolutePageURL(for: path))</loc>
            """
            if let lastModified {
                sitemap += "\n        <lastmod>\(dateFormatter.string(from: lastModified))</lastmod>"
            }
            sitemap += "\n    </url>"
        }

        let mainPages: [(String, Date?)] = [
            ("/", latestSiteDate),
            ("/blog", latestBlogDate),
            ("/about", nil),
            ("/about/publications", nil),
            ("/about/talks", nil),
            ("/about/podcasts", nil),
            ("/resources", nil),
            (SiteMeta.contentLicensePath, nil),
            ("/apps", nil),
            ("/365-days-ios-accessibility", latestDaysDate),
        ]

        for (path, lastModified) in mainPages {
            appendURL(path: path, lastModified: lastModified)
        }

        // Add app pages
        let appPages = AppsData.loadContent().apps.flatMap { app in
            [
                "/apps/\(app.slug)",
                "/apps/\(app.slug)/terms",
                "/apps/\(app.slug)/privacy",
            ]
        }

        let pressPages = AppsData.loadContent().apps
            .filter { AppPressKits.appSlugs.contains($0.slug) }
            .map { "/apps/\($0.slug)/press" }

        for path in appPages + pressPages {
            appendURL(path: path)
        }

        // Add long-form blog posts from Content/post (Ignite articles aren't available here).
        BuildLogger.detail("Adding \(blogPosts.count) blog post URLs")
        for post in blogPosts {
            appendURL(path: post.path, lastModified: post.lastModifiedDate)
        }

        // Add Ignite blog tag index pages generated under Build/tags.
        let blogTagPaths = BlogSitemapEntry.blogTagPaths()
        BuildLogger.detail("Adding \(blogTagPaths.count) blog tag URLs")
        for tagPath in blogTagPaths {
            let slug = String(tagPath.dropFirst("/tags/".count))
            let matchingDates = tagPath == "/tags"
                ? blogPosts.map(\.lastModifiedDate)
                : blogPosts
                    .filter { post in post.tags.contains { $0.convertedToSlug() == slug } }
                    .map(\.lastModifiedDate)
            appendURL(path: tagPath, lastModified: matchingDates.max())
        }

        // Add 365 Days posts
        BuildLogger.detail("Adding \(days365Posts.count) 365 Days post URLs")
        for post in days365Posts {
            appendURL(path: post.path, lastModified: post.modifiedDate ?? post.date)
        }

        // Pagination page 2+ are noindex and omitted from the sitemap; page 1 hub stays indexed.

        // Add tag pages (page 1 only; pagination is noindex)
        let allTags = Days365Loader.allTags()
        var tagPageCount = 0
        BuildLogger.detail("Adding 365 Days tag URLs")
        for tag in allTags {
            let tagSlug = Days365Loader.tagSlug(for: tag)
            let baseTagPath = "/365-days-ios-accessibility/tag/\(tagSlug)"
            let tagDate = Days365Loader.posts(withTag: tag)
                .map { $0.modifiedDate ?? $0.date }
                .max()
            appendURL(path: baseTagPath, lastModified: tagDate)
            tagPageCount += 1
        }
        BuildLogger.detail("Added \(tagPageCount) 365 Days tag URLs")

        sitemap += "\n</urlset>"

        // Write enhanced sitemap
        let fileManager = FileManager.default
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let buildDirectory = currentDirectory.appendingPathComponent("Build")
        let sitemapFile = buildDirectory.appendingPathComponent("sitemap.xml")
        
        do {
            try sitemap.write(to: sitemapFile, atomically: true, encoding: .utf8)
            let totalURLs = mainPages.count
                + appPages.count + pressPages.count
                + blogPosts.count
                + blogTagPaths.count
                + days365Posts.count
                + tagPageCount
            BuildLogger.success(.sitemap, "generated enhanced sitemap with \(totalURLs) URLs")
        } catch {
            BuildLogger.failure(.sitemap, "could not write enhanced sitemap: \(error.localizedDescription)")
        }
    }
    
    /// Generate image sitemap for better image SEO
    static func generateImageSitemap() async {
        BuildLogger.step(.imageSitemap, "generating image sitemap")
        
        var imageSitemap = """
        <?xml version="1.0" encoding="UTF-8"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
                xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
        """
        
        // Add images from long-form blog posts
        let blogPosts = BlogSitemapEntry.loadAll()
        let blogImageCount = blogPosts.compactMap(\.image).count
        BuildLogger.detail("Adding \(blogImageCount) images from blog posts")
        for post in blogPosts {
            guard let imagePath = post.image else { continue }
            let imageURL = "https://accessibilityupto11.com\(imagePath)"

            imageSitemap += """
            <url>
                <loc>\(SiteMeta.absolutePageURL(for: post.path))</loc>
                <image:image>
                    <image:loc>\(imageURL)</image:loc>
                    <image:title>\(xmlEscape(post.title))</image:title>
                    <image:caption>\(xmlEscape(post.title))</image:caption>
                </image:image>
            </url>
            """
        }

        // Add images from 365 Days posts
        let days365Posts = Days365Loader.loadPosts()
        let days365ImageCount = days365Posts.compactMap { $0.image }.count
        BuildLogger.detail("Adding \(days365ImageCount) images from 365 Days posts")
        for post in days365Posts {
            if let imagePath = post.image {
                let imageTitle = post.topicTitle
                let imageCaption = post.excerpt
                let imageURL = "https://accessibilityupto11.com\(imagePath)"
                
                imageSitemap += """
                <url>
                    <loc>\(SiteMeta.absolutePageURL(for: post.path))</loc>
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
            ("/Images/Site/Global/Logo-dark.png", "Accessibility up to 11! Logo - Dark Mode", "iOS accessibility development blog logo for dark mode"),
            ("/Images/Site/Global/LogoDarkMode.png", "Accessibility up to 11! Logo - Dark Mode", "iOS accessibility development blog logo for dark mode")
        ]
        BuildLogger.detail("Adding \(siteImages.count) site branding images")
        
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
            let imageCount = blogImageCount + days365ImageCount + siteImages.count
            BuildLogger.success(.imageSitemap, "generated image sitemap with \(imageCount) images")
        } catch {
            BuildLogger.failure(.imageSitemap, "could not write image sitemap: \(error.localizedDescription)")
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

    /// Copy the curated robots.txt from Assets, replacing Ignite's generated file.
    static func publishRobotsTxt() throws {
        BuildLogger.step(.sitemap, "publishing curated robots.txt")
        let fileManager = FileManager.default
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let source = currentDirectory.appendingPathComponent("Assets/robots.txt")
        let destination = currentDirectory.appendingPathComponent("Build/robots.txt")

        guard fileManager.fileExists(atPath: source.path) else {
            throw NSError(
                domain: "AccessibilityUpTo11Website",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Missing Assets/robots.txt at \(source.path)"]
            )
        }

        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        try fileManager.copyItem(at: source, to: destination)
        BuildLogger.success(.sitemap, "published curated robots.txt")
    }

    /// Run social metadata checks against generated HTML.
    static func runSocialMetaValidation() throws {
        if ProcessInfo.processInfo.environment["SKIP_SOCIAL_META_CHECK"] == "1" {
            BuildLogger.warning(.socialMetadata, "skipping validation because SKIP_SOCIAL_META_CHECK=1")
            return
        }

        BuildLogger.step(.socialMetadata, "validating generated pages")
        let process = Process()
        process.currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["swift", "Scripts/CheckSocialMeta.swift", "--no-build"]

        var environment = ProcessInfo.processInfo.environment
        environment["SWIFTPM_MODULECACHE_OVERRIDE"] = "/tmp/swiftpm-module-cache"
        environment["CLANG_MODULE_CACHE_PATH"] = "/tmp/clang-module-cache"
        environment["SKIP_SOCIAL_META_CHECK"] = "1"
        environment["SOCIAL_META_PROJECT_DIR"] = process.currentDirectoryURL?.path
        environment["SOCIAL_META_BUILD_DIR"] = process.currentDirectoryURL?.appendingPathComponent("Build").path
        process.environment = environment

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            throw NSError(
                domain: "AccessibilityUpTo11Website",
                code: Int(process.terminationStatus),
                userInfo: [
                    NSLocalizedDescriptionKey: "Social metadata validation failed with status \(process.terminationStatus)."
                ]
            )
        }

        BuildLogger.success(.socialMetadata, "validation completed")
    }

    static func publishUniversalLinksAssociationFile() throws {
        let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        BuildLogger.step(.universalLinks, "publishing apple-app-site-association")
        try UniversalLinkConfiguration.publishAASA(projectDirectory: currentDirectory)
        BuildLogger.success(.universalLinks, "published apple-app-site-association")
    }
}

struct AccessibilityUpTo11Site: Site {    
    var name = "Accessibility up to 11!"
    var titleSuffix = " • Accessibility up to 11!"
    var url = URL(static: "https://accessibilityupto11.com")
    var builtInIconsEnabled = true
    var description = "iOS accessibility development blog and resources for developers who want to make their apps accessible to everyone."
    
    var author = "Dani Devesa Derksen-Staats"
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
            PublicationsPage(),
            TalksPage(),
            PodcastsPage(),
            Resources(),
            ContentLicense(),
            Apps()
        ]

        let visibleApps = AppsData.loadContent().apps
        let visibleAppSlugs = Set(visibleApps.map(\.slug))

        for app in visibleApps {
            pages.append(UniversalAppPage(appIdentifier: app.slug, pageType: .main))
            pages.append(UniversalAppPage(appIdentifier: app.slug, pageType: .terms))
            pages.append(UniversalAppPage(appIdentifier: app.slug, pageType: .privacy))
            if AppPressKits.appSlugs.contains(app.slug) {
                pages.append(UniversalAppPage(appIdentifier: app.slug, pageType: .press))
            }
        }

        for slug in UniversalLinkConfiguration.openPageSlugs where visibleAppSlugs.contains(slug) {
            pages.append(UniversalAppPage(appIdentifier: slug, pageType: .open))
        }
        
        // Add all 365 days posts and tag pages
        pages.append(contentsOf: Days365StaticPages.generateAllPages())
        
        return pages
    }
    
}
