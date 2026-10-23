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
    
    /// Absolute URL helper.
    var absoluteURL: String { SiteMeta.absolutePageURL(for: path) }
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
        type: MetaContext.ContentType
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
            type: type
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
            title: post.seoTitle,
            description: post.excerpt,
            path: post.path,
            image: post.image,
            imageAlt: post.topicTitle,
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
        case .open: suffix = " • Open in App"
        case .press: suffix = " • Press Kit"
        }
        
        let description: String
        switch pageType {
        case .main:
            description = app.description
        case .terms:
            description = "Terms and conditions for \(app.title), including usage and support information."
        case .privacy:
            description = "Privacy policy for \(app.title), including data collection, usage, and protection details."
        case .open:
            description = "Open \(app.title) in the app when installed, with automatic App Store fallback."
        case .press:
            description = "Facts, copy, full-resolution screenshots, app icons, and contact details for coverage of \(app.title)"
        }
        
        return page(
            title: "\(app.title)\(suffix)",
            description: description,
            path: "/apps/\(app.slug)\(pageType.pathSegment)",
            image: app.imagePath,
            imageAlt: app.imageDescription,
            type: .website
        )
    }
}

/// Site-level constants reused across metadata generation.
enum SiteMeta {
    static let baseURL = "https://accessibilityupto11.com"
    static let defaultImage = "/Images/Site/Global/LogoShare.png"
    static let defaultImageAlt = "Accessibility up to 11! logo"
    static let defaultDescription = "iOS accessibility development blog and resources for developers who want to make their apps accessible to everyone."
    static let metaDescriptionLimit = 160
    static let contentLicenseName = "Creative Commons Attribution 4.0 International (CC BY 4.0)"
    static let contentLicenseURL = "https://creativecommons.org/licenses/by/4.0/"
    static let contentLicensePath = "/content-license"
    static let contentLicensePageURL = absolutePageURL(for: contentLicensePath)
    static let organizationID = baseURL + "/#organization"
    static let websiteID = baseURL + "/#website"
    static let authorID = baseURL + "/about/#person"
    static let authorPageURL = baseURL + "/about/"
    
    static func bestDescription(_ description: String) -> String {
        let resolved = description.isEmpty ? defaultDescription : description
        return metaDescription(resolved)
    }

    /// Truncate descriptions for meta/OG/Twitter/JSON-LD at a word boundary.
    static func metaDescription(_ description: String, limit: Int = metaDescriptionLimit) -> String {
        let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > limit else { return trimmed }

        let truncated = String(trimmed.prefix(limit))
        if let lastSpace = truncated.lastIndex(of: " ") {
            return String(truncated[..<lastSpace]).trimmingCharacters(in: .whitespacesAndNewlines) + "…"
        }

        return truncated.trimmingCharacters(in: .whitespacesAndNewlines) + "…"
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
    
    /// Canonical path for an HTML page. GitHub Pages serves directory-backed
    /// pages with a trailing slash, so our declared URLs should match it.
    static func canonicalPagePath(_ path: String) -> String {
        guard !path.isEmpty else { return "/" }

        let prefix = path.hasPrefix("/") ? "" : "/"
        let normalized = prefix + path
        guard normalized != "/", !normalized.hasSuffix("/") else {
            return normalized
        }

        let lastComponent = normalized.split(separator: "/").last.map(String.init) ?? ""
        guard !lastComponent.contains(".") else { return normalized }
        return normalized + "/"
    }

    static func absolutePageURL(for path: String) -> String {
        if path.hasPrefix("http://") || path.hasPrefix("https://") {
            guard path.hasPrefix(baseURL),
                  var components = URLComponents(string: path)
            else {
                return path
            }
            components.path = canonicalPagePath(components.path)
            return components.string ?? path
        }

        return baseURL + canonicalPagePath(path)
    }

    static func absoluteAssetURL(for path: String) -> String {
        if path.hasPrefix("http://") || path.hasPrefix("https://") {
            return path
        }
        return baseURL + (path.hasPrefix("/") ? path : "/" + path)
    }
    
    static func absoluteImageURL(for imagePath: String) -> String {
        absoluteAssetURL(for: imagePath)
    }
    
    static func imageURL(_ imagePath: String?) -> URL? {
        URL(string: absoluteImageURL(for: bestImagePath(imagePath)))
    }
}

/// Ignite 0.6 does not escape attribute values in `MetaTag` or text in
/// `Title`, so metadata must be escaped before it reaches those elements.
enum HTMLMetadataEscaper {
    static func attribute(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    static func text(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
