import Foundation
import Ignite

@main
struct AccessibilityUpTo11Website {
    static func main() async {
        var site = AccessibilityUpTo11Site()

        do {
            try await site.publish()
        } catch {
            print(error.localizedDescription)
        }
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
        return [
            Blog(),
            About(),
            Apps(),
            MoreContent(),
            // App pages
            MestreApp(),
            XarraApp(),
            // Terms pages
            MestreTerms(),
            XarraTerms(),
            // Privacy pages
            MestrePrivacy(),
            XarraPrivacy()
        ]
    }
    
}
