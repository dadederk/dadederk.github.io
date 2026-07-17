import Foundation
import Ignite

struct MainLayout: Layout {
    @Environment(\.page) var page
    @Environment(\.site) var site
    @Environment(\.author) var author
    @Environment(\.articles) var articles
    
    @MainActor var body: some Document {
        let pagePath = page.url.path
        let isPostContentPage = pagePath.hasPrefix("/post/") || pagePath.hasPrefix("/365-days-ios-accessibility/day-")
        let horizontalContentPadding = isPostContentPage ? 12 : 20
        let meta = metaContext()
        let assetVersion = "2026-06-23-1"
        let isPaginatedListing = pagePath.contains("/page-")
        let robotsContent = isPaginatedListing
            ? "noindex, follow"
            : "index, follow, max-snippet:-1, max-image-preview:large"
        let googlebotContent = isPaginatedListing ? "noindex, follow" : "index, follow"
        
        PlainDocument {
            Head {
                MetaTag.utf8
                MetaTag.flexibleViewport

                if !meta.description.isEmpty {
                    MetaTag(name: "description", content: meta.description)
                }

                if !author.isEmpty {
                    MetaTag(name: "author", content: author)
                }

                MetaTag.generator
                Title(meta.title)

                MetaLink.standardCSS
                MetaLink(href: "/css/prism-xcode-dark.css", rel: "stylesheet")
                    .data("highlight-theme", "xcode-dark")
                MetaLink(href: "/css/prism-xcode-light.css", rel: "stylesheet")
                    .data("highlight-theme", "xcode-light")
                MetaLink(href: "/css/prism-plugins.css", rel: "stylesheet")
                MetaLink.iconCSS
                MetaLink(href: page.url, rel: "canonical")

                if let markdownAlternatePath = Self.markdownAlternatePath(for: pagePath) {
                    MetaLink(href: markdownAlternatePath, rel: "alternate")
                        .customAttribute(name: "type", value: "text/markdown")
                }

                MetaTag(property: "og:site_name", content: site.name)
                MetaTag(property: "og:image", content: meta.imageURL)
                MetaTag(name: "twitter:image", content: meta.imageURL)
                MetaTag(property: "og:title", content: meta.title)
                MetaTag(name: "twitter:title", content: meta.title)

                if !meta.description.isEmpty {
                    MetaTag(property: "og:description", content: meta.description)
                    MetaTag(name: "twitter:description", content: meta.description)
                }

                MetaTag(property: "og:url", content: meta.absoluteURL)

                if let twitterDomain = Self.twitterDomain(from: page.url) {
                    MetaTag(name: "twitter:domain", content: twitterDomain)
                }

                MetaTag(name: "twitter:card", content: "summary_large_image")
                MetaTag(name: "twitter:dnt", content: "on")

                MetaTag(name: "keywords", content: "iOS, accessibility, a11y, Swift, VoiceOver, development")
                MetaTag(name: "robots", content: robotsContent)
                MetaTag(name: "googlebot", content: googlebotContent)

                MetaTag(property: "og:type", content: meta.type.rawValue)
                MetaTag(property: "og:locale", content: "en_US")
                MetaTag(property: "og:image:alt", content: meta.imageAlt)
                MetaTag(name: "twitter:image:alt", content: meta.imageAlt)
                MetaTag(name: "twitter:site", content: "@dadederk")
                MetaTag(name: "twitter:creator", content: "@dadederk")
                
                MetaLink(href: "/css/ignite-core.min.css?v=\(assetVersion)", rel: "stylesheet")
                MetaLink(href: "/custom-navigation.css?v=\(assetVersion)", rel: "stylesheet")
                MetaLink(href: "/Images/Site/Global/a11yupto11favicon.png", rel: "icon")
                MetaLink(href: "/Images/Site/Global/a11yupto11favicon.png", rel: "apple-touch-icon")
                MetaLink(href: SiteMeta.contentLicenseURL, rel: "license")

                Script(code: """
                (function() {
                    // Set theme data attributes immediately
                    document.documentElement.setAttribute('data-light-theme', 'accessibility-up-to11-light');
                    document.documentElement.setAttribute('data-dark-theme', 'accessibility-up-to11-dark-dark');

                    // Apply theme immediately based on system preference
                    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
                    const themeID = prefersDark ? 'accessibility-up-to11-dark-dark' : 'accessibility-up-to11-light';
                    document.documentElement.setAttribute('data-bs-theme', themeID);

                    // Apply syntax highlighting theme immediately
                    const syntaxTheme = getComputedStyle(document.documentElement)
                        .getPropertyValue('--syntax-highlight-theme').trim().replace(/"/g, '');
                    if (syntaxTheme) {
                        document.querySelectorAll('link[data-highlight-theme]').forEach(link => {
                            link.setAttribute('disabled', 'disabled');
                        });
                        const themeLink = document.querySelector(`link[data-highlight-theme="${syntaxTheme}"]`);
                        if (themeLink) {
                            themeLink.removeAttribute('disabled');
                        }
                    }
                })();
                """)
            }
            .standardHeadersDisabled()
            
            Body {
                LogoNavBar()
                
                // Main content area
                Section {
                    content
                }
                .id("main-content")
                .padding(.horizontal, horizontalContentPadding)
                .padding(.top, 24)
                .padding(.bottom, 80)
                
                // Footer - Fixed bottom implementation
                Section {
                    HStack(alignment: .center) {
                        Text {
                            "Created in Swift with "
                            Link("Ignite.", target: "https://github.com/twostraws/Ignite")
                        }
                        .class("site-footer-primary")

                        Link(target: "https://swiftforswifts.org") {
                            Image(decorative: "https://swiftforswifts.org/downloads/swift-for-swifts-icon.png")
                                .resizable()
                                .frame(height: .em(2.0))
                        }
                        
                        Link("Supporting Swift for Swifts", target: "https://swiftforswifts.org/")
                            .target(.newWindow)
                            .relationship(.noOpener)
                            .class("site-footer-support-link")
                    }
                    .class("site-footer-row")
                    .style(.justifyContent, "center")
                    .style(.width, "100%")
                }
                .position(.fixedBottom)
                .padding(.vertical, 14)
                .horizontalAlignment(.center)
                .style(.backgroundColor, "var(--bs-secondary-bg)")
                .style(.zIndex, "900")
                .border(.gray, edges: .top)
                .ignorePageGutters()
            }
            .data("current-page", page.url.path)
        }
    }
}

extension MainLayout {
    @MainActor func metaContext() -> MetaContext {
        let path = page.url.path
        let title = page.title
        let defaultType: MetaContext.ContentType = path.hasPrefix("/post/") ? .article : .website

        // 365 Days individual post
        if path.hasPrefix("/365-days-ios-accessibility/") {
            let slug = path.replacingOccurrences(of: "/365-days-ios-accessibility/", with: "")
            if let post = Days365Loader.post(withFileName: slug) {
                return MetaBuilder.days365(post)
            }
        }

        // Blog post — truncate descriptions via MetaBuilder; images resolved to absolute URLs.
        if path.hasPrefix("/post/") {
            return MetaBuilder.page(
                title: title,
                description: page.description,
                path: path,
                image: page.image?.absoluteString,
                imageAlt: title,
                type: .article
            )
        }
        
        // App pages
        if path.hasPrefix("/apps/") {
            let remainder = path.replacingOccurrences(of: "/apps/", with: "")
            let components = remainder.split(separator: "/", omittingEmptySubsequences: true)
            if let identifier = components.first {
                let type: UniversalAppPage.AppPageType
                if components.count > 1 {
                    switch components[1] {
                    case "terms": type = .terms
                    case "privacy": type = .privacy
                    case "open": type = .open
                    default: type = .main
                    }
                } else {
                    type = .main
                }
                
                let appsData = AppsData.loadContent()
                if let app = appsData.apps.first(where: { $0.slug.lowercased() == identifier.lowercased() }) {
                    return MetaBuilder.app(app, pageType: type)
                }
            }
        }

        if path == "/tags" || path.hasPrefix("/tags/") {
            return blogTagMeta(for: path)
        }
        
        return MetaBuilder.page(
            title: title,
            description: page.description,
            path: path,
            image: page.image?.absoluteString,
            imageAlt: title,
            type: defaultType
        )
    }

    @MainActor func blogTagMeta(for path: String) -> MetaContext {
        if path == "/tags" {
            return MetaBuilder.page(
                title: "All tags",
                description: "Browse all blog post tags on Accessibility up to 11!",
                path: path,
                image: page.image?.absoluteString,
                imageAlt: "All tags",
                type: .website
            )
        }

        let slug = String(path.dropFirst("/tags/".count))
        let tagName = Self.blogTagName(for: slug, articles: articles.all) ?? slug
        let count = articles.all.filter { article in
            article.tags?.contains { $0.convertedToSlug() == slug } ?? false
        }.count
        let postWord = count == 1 ? "post" : "posts"

        return MetaBuilder.page(
            title: "Posts tagged \(tagName)",
            description: "Browse \(count) blog \(postWord) tagged \(tagName).",
            path: path,
            image: page.image?.absoluteString,
            imageAlt: "Posts tagged \(tagName)",
            type: .website
        )
    }

    static func blogTagName(for slug: String, articles: [Article]) -> String? {
        for article in articles {
            guard let tags = article.tags else { continue }
            for tag in tags where tag.convertedToSlug() == slug {
                return tag
            }
        }
        return nil
    }

    private static func twitterDomain(from url: URL) -> String? {
        guard var host = url.host() else { return nil }
        if host.hasPrefix("www.") {
            host = String(host.dropFirst(4))
        }
        return host
    }

    /// Markdown mirror path for blog and 365 post pages only.
    static func markdownAlternatePath(for pagePath: String) -> String? {
        if pagePath.hasPrefix("/post/") {
            let slug = String(pagePath.dropFirst("/post/".count))
            guard !slug.isEmpty else { return nil }
            return "/post/\(slug).md"
        }

        if pagePath.hasPrefix("/365-days-ios-accessibility/day-") {
            let slug = String(pagePath.dropFirst("/365-days-ios-accessibility/".count))
            guard !slug.isEmpty else { return nil }
            return "/365-days-ios-accessibility/\(slug).md"
        }

        return nil
    }
}
