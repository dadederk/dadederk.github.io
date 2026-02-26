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
    var emitCustomImageTags: Bool = false
    var emitCustomDescriptionTags: Bool = false
    
    /// Absolute URL helper.
    var absoluteURL: String { SiteMeta.absoluteURL(for: path) }
    var imageURL: String { SiteMeta.absoluteImageURL(for: image) }
}

/// Centralized helpers for building per-page metadata.
enum MetaBuilder {
    /// Generic builder that applies consistent fallback behavior.
    @MainActor static func page(
        title: String,
        description: String,
        path: String,
        image: String?,
        imageAlt: String?,
        type: MetaContext.ContentType,
        emitCustomImageTags: Bool = false,
        emitCustomDescriptionTags: Bool = false
    ) -> MetaContext {
        let resolvedDescription = SiteMeta.bestDescription(description)
        let resolvedImage = SiteMeta.bestImagePath(image)
        let resolvedAlt = SiteMeta.bestImageAlt(
            preferredAlt: imageAlt,
            imagePath: resolvedImage,
            pageTitle: title
        )
        
        return MetaContext(
            title: title,
            description: resolvedDescription,
            path: path,
            image: resolvedImage,
            imageAlt: resolvedAlt,
            type: type,
            emitCustomImageTags: emitCustomImageTags,
            emitCustomDescriptionTags: emitCustomDescriptionTags
        )
    }
    
    /// Fallback/site-wide defaults.
    @MainActor static func siteFallback(title: String, path: String) -> MetaContext {
        page(
            title: title,
            description: "",
            path: path,
            image: nil,
            imageAlt: nil,
            type: .website
        )
    }
    
    /// Metadata for blog articles.
    @MainActor static func article(_ article: Article) -> MetaContext {
        page(
            title: article.title,
            description: article.description,
            path: article.path,
            image: article.image,
            imageAlt: article.imageDescription,
            type: .article
        )
    }
    
    /// Metadata for a 365 Days tip.
    @MainActor static func days365(_ post: Days365Data) -> MetaContext {
        page(
            title: post.title,
            description: post.excerpt,
            path: post.path,
            image: post.image,
            imageAlt: post.title,
            type: .article
        )
    }
    
    /// Metadata for an app page, using the app icon.
    @MainActor static func app(_ app: AppItem, pageType: UniversalAppPage.AppPageType) -> MetaContext {
        let suffix: String
        switch pageType {
        case .main: suffix = ""
        case .terms: suffix = " • Terms & Conditions"
        case .privacy: suffix = " • Privacy Policy"
        }
        
        let description = pageType == .main ? app.description : app.nameOrigin
        
        return page(
            title: "\(app.title)\(suffix)",
            description: description,
            path: "/apps/\(app.slug)\(pageType.pathSegment)",
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
    static let defaultImageAlt = "Accessibility up to 11! logo"
    static let defaultDescription = "iOS accessibility development blog and resources for developers who want to make their apps accessible to everyone."
    
    static func bestDescription(_ description: String) -> String {
        description.isEmpty ? defaultDescription : description
    }
    
    static func bestImagePath(_ imagePath: String?) -> String {
        guard let imagePath, !imagePath.isEmpty else {
            return defaultImage
        }
        return imagePath
    }
    
    static func bestImageAlt(preferredAlt: String?, imagePath: String, pageTitle: String) -> String {
        if let preferredAlt, !preferredAlt.isEmpty {
            return preferredAlt
        }
        
        if imagePath == defaultImage {
            return defaultImageAlt
        }
        
        return pageTitle.isEmpty ? defaultImageAlt : pageTitle
    }
    
    static func absoluteURL(for path: String) -> String {
        if path.hasPrefix("http://") || path.hasPrefix("https://") {
            return path
        }
        
        if path.hasPrefix("/") {
            return baseURL + path
        }
        
        return baseURL + "/" + path
    }
    
    static func absoluteImageURL(for imagePath: String) -> String {
        absoluteURL(for: imagePath)
    }
    
    static func imageURL(_ imagePath: String?) -> URL? {
        URL(string: absoluteImageURL(for: bestImagePath(imagePath)))
    }
}
