import Foundation
import Ignite

/// Unified metadata description used to render OG/Twitter/SEO tags.
struct MetaContext {
    enum ContentType: String {
        case website = "website"
        case article = "article"
    }
    
    var title: String
    var description: String
    var path: String
    var image: String
    var imageAlt: String
    var type: ContentType
    var twitterCard: String = "summary_large_image"
    
    /// Absolute URL helper.
    var absoluteURL: String { SiteMeta.baseURL + path }
}

/// Centralized helpers for building per-page metadata.
enum MetaBuilder {
    /// Fallback/site-wide defaults.
    @MainActor static func siteFallback(title: String, path: String) -> MetaContext {
        MetaContext(
            title: title,
            description: SiteMeta.defaultDescription,
            path: path,
            image: SiteMeta.defaultImage,
            imageAlt: "Accessibility up to 11! logo",
            type: .website
        )
    }
    
    /// Metadata for blog articles.
    @MainActor static func article(_ article: Article) -> MetaContext {
        MetaContext(
            title: article.title,
            description: article.description,
            path: article.path,
            image: article.image ?? SiteMeta.defaultImage,
            imageAlt: article.title,
            type: .article
        )
    }
    
    /// Metadata for a 365 Days tip.
    @MainActor static func days365(_ post: Days365Data) -> MetaContext {
        MetaContext(
            title: post.title,
            description: post.excerpt,
            path: post.path,
            image: post.image ?? SiteMeta.defaultImage,
            imageAlt: post.title,
            type: .article
        )
    }
    
    /// Metadata for an app page, using the app icon.
    @MainActor static func app(_ app: AppItem, appIdentifier: String, pageType: UniversalAppPage.AppPageType) -> MetaContext {
        let suffix: String
        switch pageType {
        case .main: suffix = ""
        case .terms: suffix = " • Terms & Conditions"
        case .privacy: suffix = " • Privacy Policy"
        }
        
        let description = pageType == .main ? app.description : app.nameOrigin
        
        return MetaContext(
            title: "\(app.title)\(suffix)",
            description: description,
            path: "/apps/\(appIdentifier)\(pageType.pathSegment)",
            image: app.imagePath,
            imageAlt: app.imageDescription,
            type: .article
        )
    }
}

/// Site-level constants reused across metadata generation.
enum SiteMeta {
    static let baseURL = "https://accessibilityupto11.com"
    static let defaultImage = "/Images/Site/Global/LogoShare.png"
    static let defaultDescription = "iOS accessibility development blog and resources for developers who want to make their apps accessible to everyone."
}
