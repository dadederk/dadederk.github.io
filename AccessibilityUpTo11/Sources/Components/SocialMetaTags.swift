import Foundation
import Ignite

/// Helper functions for generating Open Graph and Twitter Card meta tags based on page type
enum SocialMetaTags {
    /// Meta tag data structure
    struct TagData {
        let ogType: String
        let ogTitle: String?
        let ogDescription: String?
        let ogUrl: String
        let ogImage: String
        let ogImageAlt: String
        let ogLocale: String
        let twitterCard: String?
        let twitterTitle: String?
        let twitterDescription: String?
        let twitterImage: String
        let twitterImageAlt: String
    }
    
    /// Gets appropriate meta tag data for a given page path
    @MainActor static func getTagData(for pagePath: String) -> TagData {
        // Days365 post
        if pagePath.hasPrefix("/365-days-ios-accessibility/day-") {
            let postFileName = pagePath.replacingOccurrences(of: "/365-days-ios-accessibility/", with: "")
            if let post = Days365Loader.post(withFileName: postFileName) {
                return TagData(
                    ogType: "article",
                    ogTitle: nil,
                    ogDescription: nil,
                    ogUrl: "https://accessibilityupto11.com\(post.path)",
                    ogImage: post.image != nil ? "https://accessibilityupto11.com\(post.image!)" : "https://accessibilityupto11.com/Images/Site/Global/LogoShare.png",
                    ogImageAlt: post.image != nil ? "\(post.title) - #365DaysIOSAccessibility" : "Accessibility up to 11! Logo",
                    ogLocale: "en_US",
                    twitterCard: nil,
                    twitterTitle: nil,
                    twitterDescription: nil,
                    twitterImage: post.image != nil ? "https://accessibilityupto11.com\(post.image!)" : "https://accessibilityupto11.com/Images/Site/Global/LogoShare.png",
                    twitterImageAlt: post.image != nil ? "\(post.title) - #365DaysIOSAccessibility" : "Accessibility up to 11! Logo"
                )
            }
        }
        
        // App page - match /apps/{identifier} or /apps/{identifier}/
        if pagePath.hasPrefix("/apps/") && !pagePath.hasSuffix("/terms") && !pagePath.hasSuffix("/privacy") {
            // Extract app identifier from path like /apps/xarra or /apps/xarra/
            let pathWithoutPrefix = pagePath.replacingOccurrences(of: "/apps/", with: "")
            let appIdentifier = pathWithoutPrefix.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            
            if !appIdentifier.isEmpty {
                let appsData = AppsData.loadContent()
                if let app = appsData.apps.first(where: { $0.title.lowercased() == appIdentifier.lowercased() }) {
                    let description = app.description.components(separatedBy: "\n\n").first ?? app.subtitle
                    let title = "\(app.title) - \(app.subtitle)"
                    
                    return TagData(
                        ogType: "website",
                        ogTitle: title,
                        ogDescription: description,
                        ogUrl: "https://accessibilityupto11.com\(pagePath)",
                        ogImage: "https://accessibilityupto11.com\(app.imagePath)",
                        ogImageAlt: app.imageDescription,
                        ogLocale: "en_US",
                        twitterCard: "summary_large_image",
                        twitterTitle: title,
                        twitterDescription: description,
                        twitterImage: "https://accessibilityupto11.com\(app.imagePath)",
                        twitterImageAlt: app.imageDescription
                    )
                }
            }
        }
        
        // Global/default tags
        return TagData(
            ogType: "website",
            ogTitle: nil,
            ogDescription: nil,
            ogUrl: "https://accessibilityupto11.com",
            ogImage: "https://accessibilityupto11.com/Images/Site/Global/LogoShare.png",
            ogImageAlt: "Accessibility up to 11! Logo",
            ogLocale: "en_US",
            twitterCard: nil,
            twitterTitle: nil,
            twitterDescription: nil,
            twitterImage: "https://accessibilityupto11.com/Images/Site/Global/LogoShare.png",
            twitterImageAlt: "Accessibility up to 11! Logo"
        )
    }
}
